LOCAL loExc as Exception 
TRY 
	
CATCH TO loExc
	SAMERROR(loExc.ErrorNo,loExc.Procedure+' ('+PROGRAM()+')',;
			loExc.LineNo,loExc.Message,loExc.LineContents,'T')
ENDTRY  