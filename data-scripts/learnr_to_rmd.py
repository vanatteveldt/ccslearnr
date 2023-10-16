"""
Convert learnr-style Rmd files into 'plain' Rmd files
by stripping exercise solutions and other learnr-specific contents
"""
import argparse
import subprocess
import re
from pathlib import Path
import sys
import frontmatter


def header(title, keep_output):
    if keep_output:
        output_opts = 'fig.path = "img/", results = TRUE'
    else:
        output_opts = 'fig.keep = "none", results = FALSE'
    return f"""---
title: "{title}"
output:
  github_document:
    toc: yes
editor_options:
  chunk_output_type: console
---

```{{r opts, echo = FALSE, message=FALSE, warning=FALSE}}
knitr::opts_chunk$set(message=FALSE, warning=FALSE, {output_opts})
library(printr)
```
  """.strip()


def convert(inf, outf):
    skip = False
    with open(outf, "w") as out:
        meta, content = frontmatter.parse(open(inf).read())
        keep_output = meta.get("learnr_to_md_options", {}).get("keep_output", True)
        header_text = header(title=meta["title"], keep_output=keep_output)
        print(header_text, file=out)
        for line in content.split("\n"):
            if re.match(
                "```{.*(remove_for_md\s*=\s*T.*|-solution|-code-check|-hint|-hint-\\d+)}",
                line,
            ):
                skip = True
            elif re.match("```{.*exercise\s*=\s*T.*}", line):
                line = re.sub(",\s*exercise\s*=\s*T(RUE)?", "", line)
            if not skip:
                print(line, file=out)
            if line.strip() == "```":
                skip = False


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("tutorials", nargs="*", help="Names of the tutorials to render")
    parser.add_argument("--readme", help="Update the readme file", action="store_true")
    args = parser.parse_args()
    root = Path.cwd().parent
    infolder = root / "inst" / "tutorials"
    outfolder = root / "handouts"

    if args.readme:
        readme = (root / "README.md").open().read()

        pre = readme.find("<!-- Tutorial table -->")
        post = readme.find("<!-- /Tutorial table -->")
        if pre == -1 or post == -1:
            raise Exception("Cannot parse README")

        table = """
| Name  | Tutorial | Handout |
|-|-|
"""

        for file in infolder.glob("*/*.Rmd"):
            name = file.with_suffix("").name
            table += f"{name} | [link](https://vanatteveldt.shinyapps.io/{name}) | [link](handouts/{name}.md)\n"

        readme = readme[: (pre + 23)] + "\n\n" + table + "\n\n" + readme[post:]

        (root / "README.md").open("w").write(readme)
        print("* New README.md written")

    if not (args.tutorials or args.readme):
        print("Please select one or more tutorial to render:")
        for file in infolder.glob("*/*.Rmd"):
            print(f"- {file.with_suffix('').name:40} ({file})")
        sys.exit()

    infiles = [infolder / name / f"{name}.Rmd" for name in args.tutorials]
    for infile in infiles:
        if not infile.exists():
            raise Exception("File {infile} does not exist!")

    for infile in infiles:
        out = outfolder / infile.name
        print(f"{infile} -> {out}")
        convert(infile, out)
        subprocess.check_call(
            [
                "Rscript",
                "-e",
                f'library(rmarkdown); rmarkdown::render("{out}", rmarkdown::github_document(toc=T, html_preview=F))',
            ]
        )
