#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 29 15:12:54 2018

@author: raysun
"""

import os

cmd = 'TexturePacker'
outdim = '--width 2048 --height 2048'
outform = '--format sparrow'
outxml = '--data src/assets/out/system.xml'
outpng = '--sheet src/assets/out/system.png'
outsrc = ['src/assets/ui/*.png']

os.system(' '.join([cmd, outdim, outform, outxml, outpng]) + ' ' + ' '.join(outsrc))