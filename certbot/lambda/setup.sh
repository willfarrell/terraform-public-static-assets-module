#!/usr/bin/env sh

/usr/local/bin/virtualenv -p python3.9 venv
source venv/bin/activate

python -m pip install -r requirements.txt