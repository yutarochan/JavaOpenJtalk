#!/bin/sh
VOICE=voices/miku_alpha
echo $1 | open_jtalk \
-td $VOICE/tree-dur.inf \
-tf $VOICE/tree-lf0.inf \
-tm $VOICE/tree-mgc.inf \
-md $VOICE/dur.pdf \
-mf $VOICE/lf0.pdf \
-mm $VOICE/mgc.pdf \
-df $VOICE/lf0.win1 \
-df $VOICE/lf0.win2 \
-df $VOICE/lf0.win3 \
-dm $VOICE/mgc.win1 \
-dm $VOICE/mgc.win2 \
-dm $VOICE/mgc.win3 \
-ef $VOICE/tree-gv-lf0.inf \
-em $VOICE/tree-gv-mgc.inf \
-cf $VOICE/gv-lf0.pdf \
-cm $VOICE/gv-mgc.pdf \
-k  $VOICE/gv-switch.inf \
-x dictionary/UTF-8 \
-ow out.wav \
-ot out.log