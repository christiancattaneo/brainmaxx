#!/bin/bash

# Create directories
mkdir -p Brainmaxx/Resources/mathjax

# Download MathJax
curl -L https://github.com/mathjax/MathJax/archive/3.2.2.zip -o mathjax.zip

# Unzip and copy necessary files
unzip -j mathjax.zip 'MathJax-3.2.2/es5/tex-chtml.js' -d Brainmaxx/Resources/mathjax/

# Clean up
rm mathjax.zip

echo "✅ MathJax setup complete" 