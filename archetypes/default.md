---
title: "{{ replace .Name "-" " " | title }}"    # 文章标题（必填）
date: {{ .Date }}                                # 发布日期（自动填入当前日期）
draft: true                                      # 草稿状态（true=不发布，false=发布）
description: ""                                  # 文章描述（SEO 元标签 + 列表摘要，可选）
tags: []                                         # 标签（可选，支持多个）
categories: []                                   # 分类（可选，支持多个）
featureimage: ""                                 # 封面图路径（可选，留空使用全局默认封面）
showTableOfContents: true                        # 是否显示文章目录（可覆盖全局设置）
---
