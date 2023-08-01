"""
Convert learnr-style Rmd files into 'plain' Rmd files
by stripping exercise solutions and other learnr-specific contents
"""
import subprocess
import re

def header(title):
    return(f"""---
title: {title}
output:
  github_document:
    toc: yes
editor_options:
  chunk_output_type: console
---

```{{r opts, echo = FALSE}}
knitr::opts_chunk$set(message=FALSE, warning=FALSE, fig.path = "img/")
#library(printr)
```
  """.strip())

def convert(inf, outf):
    skip = False
    in_title = 0
    title = None

    with open(outf, "w") as out:
        for line in open(inf):
            if line.strip() == "---":
                in_title += 1
                if in_title == 2:
                    print(header(title=title), file=out)
                    continue

            if in_title == 1:
                if m := re.match("title: (.*)", line):
                    title = m.group(1)
                continue

            if re.match("```{.*(remove_for_md=T.*|-solution|-code-check)}", line):
                skip = True
            elif re.match("```{.*exercise\s*=\s*T.*}", line):
                line = re.sub(",\s*exercise\s*=\s*T(RUE)?", "", line)
            if not skip:
                print(line, file=out, end='')
            if line.strip() == "```":
                skip = False

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('files', nargs="+", help="Rmd files to convert. Note: foo.Rmd or foo-learnr.Rmd will become foo-doc.Rmd")
    args = parser.parse_args()
    for file in args.files:
        out = file.replace("-learnr.Rmd", ".Rmd")
        out = file.replace(".Rmd", "-doc.Rmd")
        convert(file, out)
        subprocess.check_call(["Rscript", "-e", f'library(rmarkdown); rmarkdown::render("{out}", rmarkdown::github_document(toc=T, html_preview=F))'])

