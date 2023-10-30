Singular Value Decomposition
================

- [Introduction](#introduction)
- [SVD to find patterns](#svd-to-find-patterns)
- [M = UDV’](#m--udv)
  - [Re-creating the original matrix](#re-creating-the-original-matrix)
- [Fewer Factors](#fewer-factors)
- [A helper function for SVD](#a-helper-function-for-svd)
  - [Creating a helper function](#creating-a-helper-function)
  - [Using the new helper function](#using-the-new-helper-function)
  - [Interpreting U, D, and V](#interpreting-u-d-and-v)
  - [Understanding the prediction](#understanding-the-prediction)
- [Conclusion](#conclusion)

<style>
.match {color: red}
li pre {border: 0px; padding: 0; margin:0}
.Info {
    background-color: rgb(204, 229, 255);
    border: 1px solid rgb(184, 218, 255);
    color: rgb(0, 64, 133);
    padding: 1em;
    margin: 1em;
}
.Info::before {
  font-weight: bold;
  content: "🛈 Information";
}
</style>

## Introduction

Singular value decomposition is a technique for reducing the
dimensionality of data by looking for patterns. Conceptually, it is very
similar to factor analysis: if multiple questions in a survey should
measure the same concept, we would expect them to have strong internal
correlation. Thus, we can represent the essence of the data with the
value of the factor (scale), rather than the individual answers.

## SVD to find patterns

Suppose we have data with two dimensions (x and y) that are highly
correlated. Let’s create this kind of data by randomly drawing x from a
normal distribution and calculating y based on x and an error:
`y = .5·x + e`:

``` r
library(tidyverse)
data <- tibble(x = rnorm(100)) |>
  mutate(y = .5*x + rnorm(length(x), sd=.25))
head(data)
```

**Exercise:** Can you plot this data to see that x and y are correlated?
Fill in the `ggplot` call and the slope for the regression line
(`abline`). How do we know what the right slope should be?

``` r
ggplot(___) + 
  geom_point() + 
  geom_abline(slope=____, color='red')
```

One way to look at this is that there is actually a latent factor that
can explain both x and y. This factor is the diagonal red line around
which the points are clustered. All the points are quite close to this
line, so if you only knew the point on that line instead of x and y, you
would never be far from the original point.

In other words: most of the variation in the points is along the red
diagonal, which could be seen as the main ‘factor’ or ‘dimension’ in the
data.

In this case, we generated the data ourselves, so we know this structure
is present. But how can we find the latent factors in real data?

## M = UDV’

With singular value decomposition, you can decompose any (normal) matrix
into three components:

- *U* gives the strength of each row (user) in each factor.
- *D* is the ‘singular value’ (strength) of each factor.
- *V’* gives the strength of each column (movie, book, etc.) in each
  factor.

The call is quite simply `svd(data)`, resulting in a list with the three
elements u, d, and v:

``` r
udv <- svd(data)
u <- udv$u
d <- udv$d
v <- udv$v
d
dim(u)
```

As you can see, the result of udv contains this data, and u is a matrix
of 100 (rows) x 2 (factors). The first factor has a weight of around 11,
while the second has a weight of around 2. Note that these numbers can
differ based on the random input, but in any case the first factor is
much more important than the second.

(Looking back at the earlier picture, the first factor represents the
red diagonal line, while the second factor is a line orthogonal to that
line – we’ll plot this later)

### Re-creating the original matrix

If you multiply these three matrices together, you get exactly the same
data back:

``` r
data2 <- u %*% diag(d) %*% t(v)
data2 <- as_tibble(data2, .name_repair = ~c("x2", "y2")) 
head(data2)
```

We can plot both data sets to be sure, plotting the new points in blue
and the old points as red crosses:

``` r
combined <- cbind(data, data2)
ggplot(combined) + 
  geom_point(aes(x=x, y=y), color="blue") + 
  geom_point(aes(x=x2, y=y2), color="red", shape=4)
```

Now you might be wondering: why would we ever want to do this?

The answer, of course, is that we don’t normally do this. However this
does show that if you keep all factors in the SVD decomposition, you
have exactly the same information as in the original data.

The next section will show how you can reduce the number of factors, and
still reproduce *most* of the data.

## Fewer Factors

It’s not very useful to perform all these calculations just to recover
the same data.

However, what is useful is that the *singular values* in d are in order
of importance. By using only the first *p* factors, we can see the
latent structure of the data.

In this case, we want to keep only 1 factor. The easiest way to do this
is to set the singular value for the other factor(s) to zero.

**Exercise**: In the code below, can you plot the new data (`data3`)
alongside the original data?

``` r
d[2] <- 0
data3 <- u %*% diag(d) %*% t(v)
```

``` r
d[2] <- 0
data3 <- u %*% diag(d) %*% t(v)
data3 <- as_tibble(data3, .name_repair = ~ c("x3", "y3"))
combined <- cbind(data, data3)
ggplot(combined) + 
  geom_point(aes(x=x, y=y), color="blue") + 
  geom_point(aes(x=x3, y=y3), color="red", shape=4)
```

As you can see, all points in `data3` (the red crosses) are now
*projected* onto the diagonal, which of course is also the original red
slope line.

## A helper function for SVD

As you have learned above, calling SVD is not very complicated. However,
the function is not very tidy-friendly, since it requires a matrix input
and returns various matrix outputs, none of which have proper column
names.

### Creating a helper function

To remedy this, the code below creates a helper function `tidy_svd`,
that uses a *long* data frame as input, and creates three tibbles in
addition to the default svd outputs: `result$u_values` and
`result$v_values` are the row and column values (factor loadings), while
`result$predicions` is the approximation of the original matrix, using
only the number of dimensions given:

``` r
tidy_svd = function(long_data, rows_from, columns_from, values_from, ndimensions=10) {
  # center the data
  long_data[[values_from]] = long_data[[values_from]] - mean(long_data[[values_from]], na.rm=TRUE)
  
  # pivot and cast to wide matrix
  m <- long_data |>
    select(all_of(c(rows_from, columns_from, values_from))) |>
    na.omit() |>
    pivot_wider(names_from=columns_from, values_from=values_from, values_fill = 0) |>
    column_to_rownames(rows_from) |>
    as.matrix()
  
  # Compute SVD
  udv <- svd(m, ndimensions, ndimensions)
  
  # Create nicer looking versions of u, d, and v
  dimnames <- str_c("V", 1:ndimensions)
  udv$d <- udv$d[1:ndimensions]
  udv$weights <- tibble(dimension=dimnames, weight=udv$d)

  colnames(udv$v) <- dimnames
  rownames(udv$v) <- colnames(m)
  udv$v_values = as_tibble(udv$v, rownames=columns_from) |> 
    pivot_longer(-columns_from, names_to="dimension", values_to="v_value")

  colnames(udv$u) <- dimnames
  rownames(udv$u) <- rownames(m)
  udv$u_values = as_tibble(udv$u, rownames=rows_from) |> 
    pivot_longer(-rows_from, names_to="dimension", values_to="u_value")
  
  # Add predictions
  p <- (udv$u %*% diag(udv$d, nrow=length(udv$d)) %*% t(udv$v)) 
  udv$predictions = as_tibble(p, rownames=rows_from) |>
    pivot_longer(-rows_from, names_to=columns_from, values_to="prediction")
  return(udv)
}
```

To load this function, you can copy and run the code above, but you can
also load it directly from the internet:

``` r
source('https://gist.github.com/vanatteveldt/865202bdea23de2e6457d59d25f0ab37/raw')
```

### Using the new helper function

To use the new function, let’s create a long user-item rating matrix
from the random data created above, but let’s set user 1’s review of
item x to missing:

``` r
long_data = data |> 
  add_column(user=1:100) |>
  pivot_longer(-user, names_to="item") |>
  mutate(value=if_else(user==1 & item == "x", NA, value))
head(long_data)
```

Now, we can call svd using the function above and get the predicted
values:

``` r
m <- tidy_svd(long_data, rows_from="user", columns_from="item", values_from="value", ndimensions=1)
head(m$predictions)
```

As you can see, the missing value now received a prediction based on the
combined factor loadings of the user (1) and item (x).

### Interpreting U, D, and V

Assuming that items are movies and the dimensions can be interpreted as
genres (e.g. ‘action films’), we can interpret the different components
as follows: U indicates how much each user likes each genre, while V
indicates how much each movie fits into each genre. Finally, the
singular values D are the weights of each genre in predicting ones
preference.

So, the `u_values` list how much each user likes each dimension (genre
or cluster):

``` r
head(m$u_values)
```

Similarly, the `v_values` list how much each item fits into each
dimension:

``` r
head(m$v_values)
```

And the singular values `d` give the weight of each dimension. In this
case it is only a single number, but with more dimensions it would show
how important each dimension is, starting from the most important
dimension:

``` r
m$d
```

Of course, these genres would not be genres assigned by experts or
critics, but clusters of films and users as apparent from the data. So,
they could also represent ‘movies with an intricate plot’ or ‘movies
with a blond main actor’, if those features of movies are strong
predictors of people’s (dis)likes.

### Understanding the prediction

Now, let’s look again at our prediction above. In this case (with only a
single remaining dimension) it is quite easy to reproduce the
prediction:

``` r
u = m$u_values |> filter(user==1)
v = m$v_values |> filter(item=="x")
u
v
u$u_value * v$v_value * m$d
```

This could be interpreted as follows: User 1 has a slight dislike for
action films (based on their other ratings); item ‘x’ is not an action
movie (negative coefficient); so we expect user 1 to probably be
somewhat positive about that movie.

If there would be multiple dimensions (genres), you would get a similar
result by computing this score per genre, and adding them up together –
where the singular values `m$d` would then be the weight of each genre.

## Conclusion

What this tutorial showed is how SVD can be used to construct a new
dimension that contains most of the variance from the original data.
Essentially, this tesed apart the pattern `y=.5*x` from the noise
(`rnorm(length(x), sd=.25)`) of the original (constructed) data set.

Similar to factor analysis, this is useful to understand the hidden
structure in the data. In the 2-dimensional example above this is not so
hard (or useful), but it also allows you to find patterns in larger data
sets: which movies cluster into which genres, or which words cluster
into which topics?
