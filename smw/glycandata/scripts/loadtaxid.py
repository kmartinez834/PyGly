#!/bin/env python2

import sys, time, re
from collections import defaultdict
import csv

from getwiki import GlycanData, Glycan
w = GlycanData()

gtc2taxid = defaultdict(lambda: defaultdict(set))
for f in sys.argv[1:]:
  for l in open(f):
    sl = l.split()
    gtc = sl[0]
    taxid = int(sl[1])
    source = sl[2]
    if len(sl) > 3:
        sourceid = sl[3]
    else:
	sourceid = None
    gtc2taxid[gtc][(source,sourceid)].add(taxid)

for m in w.iterglycan():
    start = time.time()
    acc = m.get('accession')

    sources = set()
    for ann in list(m.annotations(property="Taxonomy", type="Taxonomy")):
	if ann.get('source') not in ('GlyTouCan', 'GlyCosmos'):
            sources.add(ann.get('source'))
    for source in sources:
        m.delete_annotations(source=source, property="Taxonomy", type="Taxonomy")
	
    for source,sourceid in gtc2taxid[acc]:
	m.set_annotation(value=list(gtc2taxid[acc][(source,sourceid)]), property="Taxonomy", 
				    source=source, sourceid=sourceid, type="Taxonomy")

    if w.put(m):
        print >>sys.stderr, "%s updated in %.2f sec"%(m.get('accession'),time.time()-start,)
    else:
        print >>sys.stderr, "%s checked in %.2f sec"%(m.get('accession'),time.time()-start,)                 
