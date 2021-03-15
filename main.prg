PARAMETERS packet,nzappolz
PUBLIC def_path,PATH_DATA,false,true
false=.f.
true=.t.
*
def_path=JUSTPATH(SYS(16))
SET default to (def_path)
IF VERSION(2)<>0
	packet='999999999'
ENDIF 
IF !TYPE('nzappolz')=='C'
	nzappolz=1 &&��� ������� ��������� ������ ������ �� ����������� �������������
ELSE
	IF ALLTRIM(nzappolz)=='Y'
		nzappolz=-100
	ELSE  
		nzappolz=VAL(nzappolz)
	ENDIF 	
ENDIF 
IF !TYPE('packet')=='C'
	packet=''
ENDIF

DO case
	CASE VAL(packet)=1
		_screen.Caption='�������������� - �������� � �������������'
	CASE VAL(packet)=2
		_screen.Caption='�������������� - �������� ���� ���������� �����'
	CASE VAL(packet)=3
		_screen.Caption='�������������� - �������� �����'
	CASE VAL(packet)=4
		_screen.Caption='�������������� - ��������� �����'
	CASE VAL(packet)=5
		_screen.Caption='�������������� - ������ �����������'	
ENDCASE 
  
CLOSE DATABASES ALL
CLOSE TABLES ALL
SET BELL OFF
SET PATH TO FORMS,reports,prg,menu,classes,bitmap,;
		..\general,..\general\vybgraf,..\general\msg,..\general\forms
SET PROCEDURE TO union,msg,prg2009,main,prg_general,class_vybgraf
SET CLASSLIB TO kvart,vklnd,thermometr,vybgraf,samclass
SET REPORTBEHAVIOR 80
*
=INIF_INIT(ADDBS(def_path)+'asurg.ini')
=PRSSET() &&��������� SET
=PRINIT()
ON KEY LABEL '"'
SET SYSMENU OFF 
SET CURSOR ON 
SET REPROCESS TO 1
*��������� ���� � �� �� ini-�����	
PUBLIC PATH_DATA,P_SPR,P_DAT,P_SAM,P_PRG,PUTI,P_156,P_157,P_SUBI,P_KRED	
LOCAL tmp_path		
tmp_path=INIF_READ('MAIN','PATH')
IF LEFT(tmp_path,5)=='ERROR'
	PATH_DATA=ADDBS(SUBSTR(def_path,1,RAT('\',def_path)-1))
ELSE
	PATH_DATA=ADDBS(tmp_path)
ENDIF 
P_157=PATH_DATA+'BD157\'
P_SPR=PATH_DATA+'SPRAV\'
P_DAT=PATH_DATA+'FOND\DATA\'&&���� � �� �.�.
P_156=P_DAT
P_SAM=PATH_DATA+'SAM\BDSAM'
p_PRG=PATH_DATA
PUTI=PATH_DATA
P_SUBI=PATH_DATA+'SUBI\' &&���� � �� ��������
P_KRED=PATH_DATA+'KRED\' &&���� � �� �������

IF VERSION(2)=0
	on error do samerror with ERROR(),PROGRAM(),LINENO(),MESSAGE(),MESSAGE(1)
ENDIF

*���������� ��� ������ ���������� kvart
PUBLIC rk5,rk6,robl,rab_prf
store '' to rk5,rk6,robl,rab_prf
*����� � ����� �� ���������
PUBLIC color_err,color_act,kr_fontsize,kr_fontbold,color_info,color_yes
color_err=RGB(255,200,200) &&���� ��� ������ ��������� �� �������
color_act=RGB(150,250,230) &&���� ��������� ���� �����
color_info=RGB(200,200,255) &&���� ��� ������ �������������� ���������
color_yes=RGB(164,255,164)	&&���� ��� ������ ���������� �� �������� ����������	
kr_fontsize=12 &&������ ������ ����� �����
kr_fontbold=.t. &&�������� ������ ����� �����
*����������� �������
IF FILE(ADDBS(def_path)+'asurg1_h.chm')
	SET HELP TO asurg1_h.chm
ENDIF 
*����������� ������� ��������� ����
IF VERSION(2)=0
	IF SYSMETRIC(1)>800
		_screen.Width=1104
		_screen.Height=817
		_screen.AutoCenter=.t.
	ELSE
		_screen.WindowState= 2
	ENDIF 
	_screen.Closable=.f.
ENDIF
_screen.Picture='asurg.bmp' 
_screen.Visible=.t.
_screen.Icon='samz.ico'
*
LOCAL loExc as Exception 
LOCAL lnErrTry
lnErrTry=0
TRY 
	PUBLIC adm_KOD,rik_NAIM,adm_NAIM
	USE (ADDBS(P_PRG)+'TKONSTU') IN 0 
	SELECT tkonstu
	GO top
	adm_KOD=val(FIO)      && ��� ����H�=��� ����H��������, � ���. �������� ��������
	IF adm_KOD=88            && ������� �����������
		*rik_NAIM=allt(NAIM)  
	 	*adm_NAIM=allt(NAMZ)   && ����-� �����������
	ELSE
		USE (ADDBS(P_SPR)+'F0451') IN 0 
		SELECT F0451
		LOCATE FOR PREF=1.and.KOD=adm_KOD     && ����� �� ���� .cdx !!
		IF FOUND()
			rik_NAIM=ALLTRIM(nam)
			adm_NAIM=ALLTRIM(NAMZ)   && ����-� ����H��������
		ENDIF 	
	ENDIF 
	IF USED('tkonstu')
		USE IN tkonstu
	ENDIF 
	IF USED('f0451')
		USE IN f0451
	ENDIF 
	=_PRKONST()
	*��������� ����� ������������
	PUBLIC POLZ_PRAVO,POLZ_IMA,POLZ_TEL,POLZ_DOLJ,POLZ_KOM
	POLZ_PRAVO=REPLICATE('0',20)
	POLZ_IMA=SYS(0)
	POLZ_TEL=''
	POLZ_DOLJ=''
	POLZ_KOM=''
	DO CASE 
		CASE nzappolz=-100
			POLZ_PRAVO=REPLICATE('1',20)
			POLZ_IMA='�����������'
			POLZ_TEL=''
			POLZ_DOLJ=''
			POLZ_KOM=''
		CASE nzappolz=0
			POLZ_PRAVO=REPLICATE('0',20)
			POLZ_IMA=SYS(0)
			POLZ_TEL=''
			POLZ_DOLJ=''
			POLZ_KOM=''
		OTHERWISE 
			IF FILE(ADDBS(PATH_DATA)+'F0POLZ.dbf')
				USE (ADDBS(PATH_DATA)+'F0POLZ') IN 0 AGAIN
				SELECT f0polz
				GO RECORD nzappolz
				POLZ_PRAVO=TRIM(pravo)
				POLZ_IMA=ALLTRIM(ima)
				POLZ_TEL=ALLTRIM(tel)
				POLZ_DOLJ=ALLTRIM(dolj)
				POLZ_KOM=ALLTRIM(STR(kom,10))
				USE IN f0polz
			ENDIF
	ENDCASE
CATCH TO loExc
	lnErrTry=1
	SAMERROR(loExc.ErrorNo,loExc.Procedure+' ('+PROGRAM()+')',;
		loExc.LineNo,loExc.Message,loExc.LineContents,'T')
ENDTRY 	  
IF lnErrTry=1
	MESSAGEBOX('���� ������ ���������� ��� ���������',16,'��������')
	RETURN .f.
ENDIF 
*
LOCAL vozrt
*����������� �����
vozrt=.t.
if FILE(ADDBS(path_data)+'f0vxod.dbf')
   TRY 
   	USE (ADDBS(path_data)+'f0vxod') IN 0
   	SELECT f0vxod
   CATCH TO loExc
   	vozrt=.f.
   	SAMERROR(loExc.ErrorNo,loExc.Procedure+' ('+PROGRAM()+')',;
   		loExc.LineNo,loExc.Message,loExc.LineContents,'T')
   ENDTRY 
   IF vozrt
      APPEND BLANK 
      =RLOCK()
      REPLACE IMP with POLZ_IMA
      IF EMPTY(IMP)
         REPLACE IMP WITH SYS(0)
      ENDIF 
      REPLACE VX WITH DATETIME(),vix WITH CTOT(''),name_k WITH _screen.caption
      FLUSH 
   ENDIF 
ELSE 
   vozrt=.f.
ENDIF 
if .not.vozrt
   =messagebox('������� ����������� ����� ����������� ��� ���������.'+chr(13)+;
	'���������� � �������������� �����-1.',16,'')
	_screen.Icon=''
	_screen.Picture=''
	_screen.caption='Microsoft Visual FoxPro'
	SET SYSMENU TO DEFAULT
	RETURN .f.
ENDIF
*������ ��� ��������������� ������
_screen.AddObject('timer1','me_timer')
_screen.timer1.interval=15000
_screen.timer1.pth=PATH_DATA
*
=SETKEYRUS()
*����������, ������������ ����� ������������ ���������
PUBLIC gnRegion
gnRegion=3300
*���������� ����������� ������������ ������
PUBLIC gnInAdress
gnInAdress=VAL(SUBSTR(nn_FUNC,7,1))
*����������, ������������ ��������
PUBLIC gcNameProject
gcNameProject='SAMZ'
*���������� ������������ �������� �� ����������� zadom (0 ��� 10000000)
PUBLIC gnCorrectZadom
gnCorrectZadom=0
*�������������� ������ ������ �����������
IF VAL(packet)<>5
	=START_PROMPT()	 
ENDIF
*��������� ������ � ���� ������
PUBLIC gcVersionProject
=AGETFILEVERSION(laVers,'samz.exe')
IF TYPE('lavers(4)')=='C'
	gcVersionProject='samz.exe - ������ '+laVers(4)+' �� '+TTOC(FDATE('samz.exe',1))
ELSE
	gcVersionProject='����������� ������'
ENDIF 
_screen.AddObject('label1','label')
_screen.label1.top=29
_screen.label1.left=15
_screen.label1.AutoSize=.t.
_screen.label1.backstyle=0
_screen.label1.fontsize=9
_screen.label1.forecolor=RGB(155,155,155)
_screen.label1.caption=gcVersionProject
_screen.label1.visible=.t. 	
* 
*******
IF VERSION(2)=0
	DO case
		CASE VAL(packet)=1
			DO FORM sam_korr
		CASE VAL(packet)=2
			*DO FORM viewdom
		CASE VAL(packet)=3
			DO FORM vyhform
		CASE VAL(packet)=4
			DO FORM zapros
		CASE VAL(packet)=5
			DO FORM prompt
		CASE VAL(packet)=101067 AND nzappolz=-100
			_screen.Caption='������� �����'
			DO mainmenu.mpr
			READ events		
	ENDCASE 
ELSE
	_screen.Caption='������� �����'
	DO mainmenu.mpr
	READ events
ENDIF 	

IF USED('f0vxod')
	SELECT f0vxod
	replace vix WITH DATETIME()
	FLUSH 
	use in f0vxod
ENDIF
ON KEY LABEL '"'
_screen.RemoveObject('timer1') 
_screen.RemoveObject('label1')
_screen.Icon=''
_screen.Picture=''
_screen.caption='Microsoft Visual FoxPro'
SET SYSMENU TO DEFAULT
*SET HELP to
ON ERROR 
IF VERSION(2)=0
	quit
ENDIF 
RETURN 

*******************************************
*��������� ���������� ��������*************
*******************************************
PROCEDURE _PRKONST
	LOCAL fluse,oldpoint
	oldpoint=SET("Point")
	SET POINT TO ','
	=PRKONST()
	=PRKONST(,ADDBS(P_SPR)+'f0konst')
	=PRKONSTF()
	SET POINT TO oldpoint
	IF USED('tkonstu')
		fluse=.f.
	ELSE
		fluse=.t.
		USE (ADDBS(p_PRG)+'TKONSTU') IN 0 again 
	ENDIF 
	SELECT tkonstu
	SCAN 
		IF UPPER(SUBSTR(rek,1,7))=='NN_UGSH'.and.pdata=='D'
	    	nn_IZMDATE=rek
	    ENDIF
	    IF UPPER(SUBSTR(rek,1,7))=='NN_UGSH'.and.pdata=='N'
	    	nn_IZMNISX=rek
	    ENDIF  
	ENDSCAN 
	IF fluse
		USE IN tkonstu
	ENDIF         
ENDPROC 


****           PRKONSTF           ****
PROCEDURE PRKONSTF
	*��������� ���������� ���������
	LOCAL if1,uu1,uu,uuu,uukat
	uu1=allt(str(sele()))
	if1=ADDBS(P_SPR)+'F0455'
	uuu=0
	SELECT 0
	if file(if1+'.DBF')
	IF USED('F0455')
		uuu=1
		SELECT f0455
		GO top
	ELSE 
		use &if1
	ENDIF 
	set orde to 2
	PUBLIC KAT_OTS
	KAT_OTS=''
	uukat=0
	DO WHILE .not.eof()
	  if uukat<>KKAT    
	    KAT_OTS=KAT_OTS+str(KKAT,2)+','    && ���������� ���������
	    uukat=KKAT
	  ENDIF 
	  SKIP 
	ENDDO  
	KAT_OTS=subs(KAT_OTS,1,len(KAT_OTS)-1)
	IF uuu=0
		USE IN f0455
	ENDIF 	
	ENDIF 
	select &uu1
RETURN

*************************************************************************
* SAMERROR																*
*************************************************************************
* ��������� ��������� ������											*
*************************************************************************
* ����������� ���������: 							         			*
*	p1 (N) - ����� ������												*
*	p2 (C) - ��� ������������ ������, � ������� �������� ������			*
*	p3 (N) - ����� ������, �� ������� �������� ������					*
*	p4 (C) - ��������� �� ������										*
*	p5 (C)																*
*	tcVidErr (C) - ��� ����������� ������ (T - Try)						*
* ������������ ��������:                                     			*
*	���������� �� ������ ���������� � ���� samerr.dbf					*
*************************************************************************
* ��������� �.�.									         			*
*************************************************************************
* ���������:															*
*	03.03.2011 (��������� �.�.) - ���������� ����� ��������� ����������	*
*		�� ������														*
*	26.07.2011 (��������� �.�.) - ������ ��������� ���������� ������	*
*		�������	LIST MEMORY � LIST STATUS � ����� � ���������� 			*
*		����������� ������� ����� samerr.fpt							*
*************************************************************************
PROCEDURE samerror
	lparameters p1,p2,p3,p4,p5,tcVidErr
	local imfer,sodd,nomerr,lnDefSelect,lcFileMem,lcFileStat
	lnDefSelect=SELECT()
	IF !TYPE('tcVidErr')=='C'
		tcVidErr=''
	ENDIF 
	sodd=''
	imfer=ADDBS(PATH_DATA)+'samerr.dbf'
	*lcFileMem=ADDBS(def_path)+'mem.txt'
	*lcFileStat=ADDBS(def_path)+'stat.txt'
	*DELETE FILE (lcFileMem)
	*DELETE FILE (lcFileStat)
	*LIST MEMORY TO (lcFileMem) NOCONSOLE 
	*LIST STATUS TO (lcFileStat) NOCONSOLE 
	if !file(imfer)
		create table (imfer) free (dattim t,;
								 coderr i,;
							 	soderr m,;
							 	cvid c(1),;
							 	cnamep c(25),;
							 	cnamec c(40),;
							 	memerr m,;
							 	staterr m)		 
		USE IN SELECT('samerr') 					 	
	ENDIF 
	use &imfer in 0 SHARED 
	sodd='��� ������: '+ALLTRIM(STR(p1))+CHR(13)+;
		'������: '+p2+chr(13)+'����� ������: '+alltrim(str(p3))+chr(13)+'���������� ������: '+p4+chr(13)+chr(13)+p5
	insert into samerr (dattim,coderr,soderr,cvid,cnamep,cnamec) values (datetime(),p1,sodd,tcVidErr,POLZ_IMA,SYS(0))
	*SELECT samerr
	*APPEND MEMO memerr FROM (lcFileMem)
	*APPEND MEMO staterr FROM (lcFileStat)
	USE IN SELECT('samerr')
	SELECT (lnDefSelect)
	IF p1=109
		MESSAGEBOX('������ ������ ������ �������������'+CHR(13)+;
					'� ������ ������ ������������� ����������',48,'��������')
		IF tcVidErr<>'T'			
			RETURN TO MASTER 			
		ENDIF 	
	ENDIF
	IF EMPTY(tcVidErr) 
		IF MESSAGEBOX('H���� ������ '+str(p1,4)+chr(13)+'���������� ������: '+p4+chr(13)+;
		     '� ��������� '+p2+chr(13)+'� ������ � ������� '+str(p3,5)+chr(13)+p5,1+16,;
		     '������������ ��������')=2
		    CLEAR EVENTS
		    QUIT  
		ELSE      
			RETURN
		ENDIF
	ENDIF 	 	
ENDPROC