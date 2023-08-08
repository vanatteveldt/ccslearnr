"""
Convert learnr-style Rmd files into 'plain' Rmd files
by stripping exercise solutions and other learnr-specific contents
"""
import subprocess
import re
from pathlib import Path
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
                "```{.*(remove_for_md=T.*|-solution|-code-check|-hint|-hint-\\d+)}",
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
    root = Path.cwd().parent
    infolder = root / "inst" / "tutorials"
    outfolder = root / "handouts"
    for file in infolder.glob("*/*.Rmd"):
        out = outfolder / file.name
        print(f"{file} -> {out}")
        convert(file, out)
        subprocess.check_call(
            [
                "Rscript",
                "-e",
                f'library(rmarkdown); rmarkdown::render("{out}", rmarkdown::github_document(toc=T, html_preview=F))',
            ]
        )
