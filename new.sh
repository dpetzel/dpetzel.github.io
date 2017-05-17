#!/usr/bin/env bash

SECTION=${1}
TITLE=${2}


FILE_NAME=$(echo ${TITLE} | tr ' ' '_')
if ! echo ${TITLE} | grep ".md"; then
  FILE_NAME+=".md"
fi
FILE_PATH=post/${SECTION}/${FILE_NAME}
hugo new ${FILE_PATH}
sed -ie "s/title: .*/title: \"${TITLE}\"/g" content/${FILE_PATH}
sed -ie "s/categories: .*/categories: [${SECTION}]/g" content/${FILE_PATH}
vim content/${FILE_PATH}

