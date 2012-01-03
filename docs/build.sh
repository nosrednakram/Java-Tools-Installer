#!/bin/bash
pandoc --template=html.template --toc -r markdown -5 overview.markdown install.markdown user-guide.markdown appendix.markdown > index.html
cat overview.markdown install.markdown user-guide.markdown appendix.markdown > ../README.md
