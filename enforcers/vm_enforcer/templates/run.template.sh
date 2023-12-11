#!/bin/bash

{{ .Values.RuncPath }} run -d --pid-file /run/khulnasoft-enforcer.pid enforcer > /opt/khulnasoft/tmp/khulnasoft.log 2>&1

exit 0