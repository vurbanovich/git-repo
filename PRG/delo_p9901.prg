*P9901
*p9903
*p9903s
*p9907
i=0
SELECT p9901
SCAN
	lll=krs
	i=i+1
	WAIT WINDOW i nowait
ENDSCAN 
SCAN
	lll=rezkg
	i=i+1
	WAIT WINDOW i nowait
ENDSCAN 
SCAN
	lll=dop
	i=i+1
	WAIT WINDOW i nowait
ENDSCAN 
SCAN
	lll=sdelan
	i=i+1
	WAIT WINDOW i nowait
ENDSCAN
SELECT p9903 
SCAN
	lll=rezk
	i=i+1
	WAIT WINDOW i nowait
ENDSCAN 
SELECT p9903s
SCAN
	lll=rezi
	i=i+1
	WAIT WINDOW i nowait
ENDSCAN 
SELECT p9907
SCAN
	lll=dokument
	i=i+1
	WAIT WINDOW i nowait
ENDSCAN 