#!/bin/bash
sudo apt-get install python25 python25-dev
sudo apt-get install texlive-full rubber
# in case we are on ubuntu, texlive-full seems to be not full. or was it just missing python25?
sudo apt-get install python texlive-latex-extra texlive-fonts-recommended

sudo easy_install pygments
sudo easy_install sphinx