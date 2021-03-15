*************************************************************************
* CURS_KART																*
*************************************************************************
* Процедура формирования временных курсоров для карточки дома			*
*************************************************************************
* Принимаемые параметры: 							         			*
*	lnvidkorr (N) - вид корректировки (0-ввод нового дома; 1-ввод нового*
*					дома из справочника; 2-просмотр и корректировка)	*
*************************************************************************
* Урбанович В.Г.									         			*
*************************************************************************
* ИЗМЕНЕНИЯ:															*
*	17.01.2011 (Урбанович В.Г.) - доработка в связи с добавлением нового*
*		реквизита "Населенный пункт"									*
*	30.01.2013 (Урбанович В.Г.) - добавление списка предлагаемых квартир*
*	01.02.2013 (Урбанович В.Г.) - добавление списка платежных поручений	*
*	24.04.2019 (Урбанович В.Г.) - перевод в автономный режим			*
*************************************************************************
PROCEDURE CURS_KART
LPARAMETERS lnvidkorr
LOCAL ARRAY srutab(1)
LOCAL ozap,lnTek_kodd,lnTek_kodz,lcPvedn,lnObjid
IF USED('tmp_sam')
	USE IN tmp_sam
ENDIF 
SELECT f0sam.*,CAST(0 as n(6)) as kodd_in FROM f0sam WHERE .f. INTO CURSOR tmp_sam READWRITE 
DO case
	CASE lnvidkorr=0&&ввод нового
		INSERT INTO tmp_sam (flcount,objid) VALUES (3,NEW_ID('OBJID'))
	CASE lnvidkorr=1&&ввод нового из БД Жилье
		INSERT INTO tmp_sam (flcount,objid,koddz,koddj,naim1,ser,jsk,str,;
							 knp,kul,dom,kor,kmr,rik,jes,kodd_in) VALUES ;
							(2,NEW_ID('OBJID'),newfobn.kodd+10000000,newfobn.kodd,newfobn.naim1,newfobn.ser,newfobn.jsk,newfobn.str,;
							 newfobn.knp,newfobn.kul,newfobn.dom,newfobn.kor,newfobn.kmr,newfobn.rik,newfobn.jes,newfobn.kodd)
	CASE lnvidkorr=2&&просмотр и корректировка
		SELECT f0sam
		SCATTER MEMO NAME loRec
		INSERT INTO tmp_sam FROM NAME loRec
		replace tmp_sam.kodd_in WITH tmp_sam.koddz-10000000 IN tmp_sam
ENDCASE 
lnTek_kodd=tmp_sam.koddz
lnTek_kodz=tmp_sam.str
lnObjid=tmp_sam.objid	
*TMP_VID виды удержаний
USE IN SELECT('tmp_vid')
DO CASE 
	CASE INLIST(lnvidkorr,0,1)
		SELECT f0vid.*,CAST(0 as i) as nomzz FROM f0vid WHERE .f. INTO CURSOR tmp_vid READWRITE 
	CASE lnvidkorr=2
		SELECT f0vid.*,CAST(0 as i) as nomzz FROM f0vid WHERE f0vid.objid=lnObjid INTO CURSOR tmp_vid READWRITE
ENDCASE  
*TMP_PLAT платежные поручения
USE IN SELECT('tmp_plat')
DO CASE 
	CASE INLIST(lnvidkorr,0,1)
		SELECT f0plat.*,CAST(0 as i) as nomzz FROM f0plat WHERE .f. INTO CURSOR tmp_plat READWRITE 
	CASE lnvidkorr=2
		SELECT f0plat.*,CAST(0 as i) as nomzz FROM f0plat WHERE f0plat.objid=lnObjid INTO CURSOR tmp_plat READWRITE 
ENDCASE 
SELECT tmp_plat
INDEX on dplat TAG dplat
*TMP_QUE очереди ввода
USE IN SELECT('tmp_que')
DO CASE 
	CASE INLIST(lnvidkorr,0,1)
		SELECT f0queue.*,CAST(0 as i) as nomzz FROM f0queue WHERE .f. INTO CURSOR tmp_que READWRITE 
	CASE lnvidkorr=2
		SELECT f0queue.*,CAST(0 as i) as nomzz FROM f0queue WHERE f0queue.objid=lnObjid INTO CURSOR tmp_que READWRITE 
ENDCASE 
SELECT tmp_que
INDEX on LEFT(nameque,50) TAG nameque
INDEX on numque TAG numque
*TMP_SCH график ввода для очередей ввода
USE IN SELECT('tmp_sch')
DO CASE 
	CASE INLIST(lnvidkorr,0,1)
		SELECT f0sched.*,CAST(0 as i) as nomzz FROM f0sched WHERE .f. INTO CURSOR tmp_sch READWRITE 
	CASE lnvidkorr=2
		SELECT f0sched.*,CAST(0 as i) as nomzz FROM f0sched WHERE f0sched.objid=lnObjid INTO CURSOR tmp_sch READWRITE 
ENDCASE 
*TMR_AGR дополнительные соглашения
USE IN SELECT('tmp_agr')
DO CASE 
	CASE INLIST(lnvidkorr,0,1)
		SELECT f0agr.*,CAST(0 as i) as nomzz FROM f0agr WHERE .f. INTO CURSOR tmp_agr READWRITE 
	CASE lnvidkorr=2
		SELECT f0agr.*,CAST(0 as i) as nomzz FROM f0agr WHERE f0agr.objid=lnObjid INTO CURSOR tmp_agr READWRITE 
ENDCASE 
SELECT tmp_agr
INDEX on dateagr TAG dateagr
*TMP_JLINK
USE IN SELECT('tmp_jlink')
DO CASE 
	CASE INLIST(lnVidKorr,0,1)
		SELECT jillink.*,CAST('' as c(100)) as naim1 FROM jillink WHERE .f. INTO CURSOR tmp_link READWRITE 
		IF lnVidKorr=1
			IF SEEK(tmp_sam.koddj,'newfobn','kod')
				INSERT INTO tmp_link (recid,kodd,naim1) VALUES (NEW_ID('LINK'),tmp_sam.koddj,newfobn.naim1)
			ENDIF 
		ENDIF 
	CASE lnVidKorr=2
		SELECT jillink.*,newfobn.naim1 FROM jillink ;
			INNER JOIN newfobn ON jillink.kodd=newfobn.kodd ;
			WHERE jillink.objid=lnObjid INTO CURSOR tmp_link READWRITE 
ENDCASE
*TMP_DOC вложенные документы
USE IN SELECT('tmp_doc')
DO CASE 
	CASE INLIST(lnvidkorr,0,1)
		SELECT docatt.*,CAST(0 as i) as nomzz FROM docatt WHERE .f. INTO CURSOR tmp_doc READWRITE 
	CASE lnvidkorr=2
		SELECT docatt.*,CAST(0 as i) as nomzz FROM docatt WHERE docatt.objid=lnObjid INTO CURSOR tmp_doc READWRITE 
ENDCASE 
SELECT tmp_doc
INDEX on dateatt TAG dateatt
*TMP_KVR поступившие квартиры			
=CURS_KART_KVR('tmp_kvr',lnObjid,lnTek_kodd,lnTek_kodz,lnVidKorr)
ENDPROC



*************************************************************************
* CURS_KART_KVR															*
*************************************************************************
* Процедура формирования временных курсоров для показа поступивших		*
* квартир и подсчета их сумм по видам удержаний							*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tcAlias (С) - имя выходного курсора									*
*	tnObjid (N) - идентификатор объекта (objid)							*
*	tnKoddz (N) - код объекта (koddz)									*
*	tnKodz (N) - код застройщика										*
*	tnVidKorr (N) - 0 - ввод нового объекта								*
*					1 - ввод нового объекта из БД Жилье					*
*					2 - корректировка объекта							*
*					3 - запросный режим									*
* Возвращаемое значение:                                     			*
*	Результат работы помещается во временные курсоры 					*
*	определяемые параметром lcAlias										*
*************************************************************************
* Урбанович В.Г.							03.06.2019					*
*************************************************************************
PROCEDURE CURS_KART_KVR
LPARAMETERS tcAlias,tnObjid,tnKoddz,tnKodz,tnVidKorr
LOCAL lnTek_kodd,lnTek_kodz,lnVidKorr,lcPvedn,lnSelect,lnKoddz,lcNewAlias
lnSelect=SELECT()
lcNewAlias=tcAlias+'_vid'
IF USED('tmp_kvr')
	USE IN tmp_kvr
ENDIF  				
CREATE CURSOR (tcAlias) (kolkom n(1),;
						jilpl n(7,2),;
						polpl n(7,2),;
						kvart c(4),;
						kvarts n(3),;
						etaj n(2),;
						pdd n(2),;
						pvedn n(3),;
						naim c(60),;
						kpred n(8),;
						npr c(60),;
						fio c(50),;
						zadom n(8),;
						kodd n(6),;
						pved n(2),;
						adress c(150),; &&по состоянию на 21.08.2020 не adress заполняется
						pn n(10),;
						dresh d,;
						nresh c(16),;
						aktpp d,;
						psdpl n(7,2),;
						dpis d)
*промежуточная таблица объектов и источников поступлений
CREATE CURSOR objobjobj (objid i,koddz n(8),str n(8),sumpvedn c(40))
IF !EMPTY(tnObjid)
	INSERT INTO objobjobj VALUES (tnObjid,tnKoddz-gnCorrectZadom,tnKodz,'')
ELSE
	INSERT INTO objobjobj SELECT objid,koddz-gnCorrectZadom,str,'' FROM f0sam
ENDIF
SELECT objobjobj
SCAN
	lcPvedn=''
	SELECT f0vid.*,f0451.namd;
		FROM f0vid INNER JOIN f0451 ON f0vid.vidud=f0451.kod AND f0451.pref=14 ;
		WHERE f0vid.objid=objobjobj.objid ;
		INTO CURSOR tmptmp
	SELECT tmptmp
	SCAN
		lcPvedn=lcPvedn+TRIM(tmptmp.namd)
	ENDSCAN
	IF !EMPTY(lcPvedn)
		replace objobjobj.sumpvedn WITH lcPvedn IN objobjobj
	ENDIF 
ENDSCAN   
USE IN SELECT('tmptmp')
SELECT objobjobj
*					
IF (INLIST(tnVidKorr,1,2) AND !EMPTY(tnKoddz)) OR tnVidKorr=3						
	
	INSERT INTO (tcAlias) SELECT kolkom,jilpl,polpl,kvart,kvarts,etaj,pdd,pvedn,'',kpred,'',;
								fio,zadom,kodd,pved,'',pn,{},'',{},psdpl,{};
							FROM fnov ;
							INNER JOIN objobjobj ON fnov.zadom=objobjobj.koddz ;
												AND ATC(STR(fnov.pvedn,3),objobjobj.sumpvedn)>0
												*AND fnov.kodzast=objobjobj.str ;
												 
	INSERT INTO (tcAlias) SELECT kolkom,jilpl,polpl,kvart,kvarts,etaj,pdd,pvedn,'',kpred,'',;
								fio,zadom,kodd,pved,'',pn,{},'',{},psdpl,{};
							FROM a0nov;
							INNER JOIN objobjobj ON a0nov.zadom=objobjobj.koddz ;
												AND ATC(STR(a0nov.pvedn,3),objobjobj.sumpvedn)>0
												*AND a0nov.kodzast=objobjobj.str ;
							
	INSERT INTO (tcAlias) SELECT kolkom,jilpl,polpl,kvart,0,etaj,0,pvedn,'',kpred,'',;
								fio,zadom,0,0,'',pn,{},'',{},psdpl,{};
							FROM fosv;
							INNER JOIN objobjobj ON fosv.zadom=objobjobj.koddz ;
												AND ATC(STR(fosv.pvedn,3),objobjobj.sumpvedn)>0
												*AND fosv.kodzast=objobjobj.str ;
	
	INSERT INTO (tcAlias) SELECT kolkom,jilpl,polpl,kvart,0,etaj,0,pvedn,'',kpred,'',;
								fio,zadom,0,0,'',pn,{},'',{},psdpl,{};
							FROM a0osv;
							INNER JOIN objobjobj ON a0osv.zadom=objobjobj.koddz ;												
												AND ATC(STR(a0osv.pvedn,3),objobjobj.sumpvedn)>0
												*AND a0osv.kodzast=objobjobj.str ;
												
ENDIF
USE IN SELECT('objobjobj') 	
*
SELECT (tcAlias)
SCAN
	IF !EMPTY(pvedn)
		IF SEEK(pvedn,'fpvedn','fpvedn')
			replace naim WITH fpvedn.naim IN (tcAlias)
		ENDIF 
	ENDIF 
	IF !EMPTY(kpred)
		IF SEEK(kpred,'f0454','kod')
			replace npr WITH ALLTRIM(STR(f0454.kpr))+' '+f0454.npr IN (tcAlias)
		ENDIF  
	ENDIF
	IF !EMPTY(pn) 
		IF SEEK(pn,'f0sved','f0sved')
			replace dresh WITH f0sved.dresh,nresh WITH f0sved.nresh,aktpp WITH f0sved.aktpp,dpis WITH f0sved.dpis IN (tcAlias)
		ENDIF 
	ENDIF 
ENDSCAN
*
IF INLIST(tnVidKorr,0,1,2)
	IF USED(lcNewAlias)
		USE IN SELECT(lcNewAlias)
	ENDIF 
	LOCAL lnKvart,lnKvarto,lnKvartg
	CREATE CURSOR (lcNewAlias) (kod n(2),;
								nam c(60),;
								kvart n(4),;
								kvarto n(10,2),;
								kvartg n(10,2))
	SELECT (lcNewAlias) 
	INDEX on kod TAG kod
	IF USED('f0451')
		SELECT f0451
		SCAN FOR pref=14 AND kod<>5
			CALCULATE COUNT(),SUM(polpl),SUM(jilpl) FOR STR(pvedn,3)$f0451.namd TO lnKvart,lnKvarto,lnKvartg IN (tcAlias)
			IF !EMPTY(lnKvart)
				INSERT INTO (lcNewAlias) (kod,nam,kvart,kvarto,kvartg) VALUES ;
						(f0451.kod,f0451.nam,lnKvart,lnKvarto,lnKvartg)
			ENDIF 
		ENDSCAN 
	ENDIF
	GO TOP IN (lcNewAlias)
ENDIF 
*
GO TOP IN (tcAlias)
SELECT (lnSelect) 							
ENDPROC 

*************************************************************************
* ADD_IZM																*
*************************************************************************
* Процедура добавления записей в протокол изменений самзастройщиков		*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tnVidOp (N) - код вида операции										*
*					1 - режим ввода нового дома							*
*					2 - режим ввода нового дома из справочника			*
*					3 - режим корректировки дома						*
*					5 - режим удаления дома из БД Самзастройщики		*
*	tcStrKorr (C) - строка вида "0101" с указанием какие файлы 			*
*					корректировались
*************************************************************************
* Урбанович В.Г.									         			*
*************************************************************************
* ИЗМЕНЕНИЯ:															*
*	19.01.2011 (Урбанович В.Г.) - доработка в связи с добавлением нового*
*		реквизита "Населенный пункт"									*
*	05.02.2013 (Урбанович В.Г.) - добавление корректировки списков 		*
*		предлагаемых квартир и платежных поручений						*
*	21.10.2016 (Урбанович В.Г.) - добавление корректировки очередей 	*
*		и их графиков													*
*	25.04.2019 (Урбанович В.Г.) - перевод в автономный режим			*
*************************************************************************
PROCEDURE ADD_IZM
LPARAMETERS tnVidOp,tcStrKorr
LOCAL lnErrTry,llOpen,ltDateOp,lnKodd,lnSelect,lcNamTab,i,lcNamRek,lcNamRek1,;
		lcZnach,lcZnach1,lcStrIzm,lcStrIzm1,lnNz,lcNamec,lnObjid
LOCAL ARRAY laFields(1)
lnErrTry=0
llOpen=.f.
ltDateOp=DATETIME()
lnSelect=SELECT()
lcNamec=SYS(0)
IF !USED('SAMZ_IZM')
	LOCAL loExc as Exception 
	TRY 
		USE (ADDBS(p_sam)+'SAMZ_IZM') IN 0 ALIAS samz_izm
	CATCH TO loExc
		lnErrTry=1
		SAMERROR(loExc.ErrorNo,loExc.Procedure+' ('+PROGRAM()+')',;
			loExc.LineNo,loExc.Message,loExc.LineContents,'T')
	ENDTRY 
	IF lnErrTry=1
		SELECT (lnSelect)
		RETURN 	
	ELSE 
		llOpen=.t.
	ENDIF 	
ENDIF
*
DO CASE 
	CASE INLIST(tnVidOp,1,2,3)	&&ввод нового или корректировка
		SELECT tmp_sam
		GO TOP 
		lnKodd=tmp_sam.koddz
		lnObjid=tmp_sam.objid
		IF SUBSTR(tcStrKorr,1,1)=='1' OR tnVidOp=1 &&была корректировка в f0sam
			SELECT tmp_sam1
			GO TOP 
			SELECT tmp_sam
			AFIELDS(laFields)
			lcStrIzm=''
			lcStrIzm1=''
			FOR i=1 TO ALEN(laFields,1)
				lcNamRek='tmp_sam.'+ALLTRIM(laFields(i,1))
				lcNamRek1='tmp_sam1.'+ALLTRIM(laFields(i,1))
				IF !&lcNamRek==&lcNamRek1
					lcZnach=UNC_TO_STR(&lcNamRek)
					lcZnach1=UNC_TO_STR(&lcNamRek1) 
					lcStrIzm=lcStrIzm+ALLTRIM(laFields(i,1))+' = '+lcZnach1+' >>> '+lcZnach+CHR(13)  
				ENDIF 					
			ENDFOR
			IF !EMPTY(lcStrIzm)
				INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
										(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0SAM',lcStrIzm,lcNamec)
			ENDIF 
		ENDIF
		*
		IF SUBSTR(tcStrKorr,3,1)=='1' OR tnVidOp=1 &&была корректировка f0vid или ввод нового
			SELECT tmp_vid
			GO TOP 
			AFIELDS(laFields)
			
			SELECT tmp_vid1
			GO TOP 
			lcStrIzm1=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_vid1.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm1=lcStrIzm1+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
						
			SELECT tmp_vid
			lcStrIzm=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_vid.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
			IF !EMPTY(lcStrIzm1) OR EMPTY(lcStrIzm1) AND !EMPTY(lcStrIzm)
				lcStrIzm1='Прежние значения:'+CHR(13)+lcStrIzm1
			ENDIF
			IF !EMPTY(lcStrIzm) OR EMPTY(lcStrIzm) AND !EMPTY(lcStrIzm)
				lcStrIzm='Новые значения:'+CHR(13)+lcStrIzm
			ENDIF
			IF !EMPTY(lcStrIzm1) OR !EMPTY(lcStrIzm)
				lcStrIzm=lcStrIzm1+lcStrIzm
				INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
										(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0VID',lcStrIzm,lcNamec)
			ENDIF 							
		ENDIF 
		*
		IF SUBSTR(tcStrKorr,6,1)=='1' OR tnVidOp=1 &&была корректировка f0plat или ввод нового
			SELECT tmp_plat
			GO TOP 
			AFIELDS(laFields)
			
			SELECT tmp_plat1
			GO TOP 
			lcStrIzm1=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_plat1.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm1=lcStrIzm1+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
						
			SELECT tmp_plat
			lcStrIzm=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_plat.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
			IF !EMPTY(lcStrIzm1) OR EMPTY(lcStrIzm1) AND !EMPTY(lcStrIzm)
				lcStrIzm1='Прежние значения:'+CHR(13)+lcStrIzm1
			ENDIF
			IF !EMPTY(lcStrIzm) OR EMPTY(lcStrIzm) AND !EMPTY(lcStrIzm)
				lcStrIzm='Новые значения:'+CHR(13)+lcStrIzm
			ENDIF
			IF !EMPTY(lcStrIzm1) OR !EMPTY(lcStrIzm)
				lcStrIzm=lcStrIzm1+lcStrIzm
				INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
										(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0PLAT',lcStrIzm,lcNamec)
			ENDIF 							
		ENDIF 
		*
		IF SUBSTR(tcStrKorr,7,1)=='1' OR tnVidOp=1 &&была корректировка f0queue или ввод нового
			SELECT tmp_que
			GO TOP 
			AFIELDS(laFields)
			
			SELECT tmp_que1
			GO TOP 
			lcStrIzm1=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_que1.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm1=lcStrIzm1+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
						
			SELECT tmp_que
			lcStrIzm=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_que.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
			IF !EMPTY(lcStrIzm1) OR EMPTY(lcStrIzm1) AND !EMPTY(lcStrIzm)
				lcStrIzm1='Прежние значения:'+CHR(13)+lcStrIzm1
			ENDIF
			IF !EMPTY(lcStrIzm) OR EMPTY(lcStrIzm) AND !EMPTY(lcStrIzm)
				lcStrIzm='Новые значения:'+CHR(13)+lcStrIzm
			ENDIF
			IF !EMPTY(lcStrIzm1) OR !EMPTY(lcStrIzm)
				lcStrIzm=lcStrIzm1+lcStrIzm
				INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
										(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0QUEUE',lcStrIzm,lcNamec)
			ENDIF 							
		ENDIF
		*
		IF SUBSTR(tcStrKorr,8,1)=='1' OR tnVidOp=1 &&была корректировка f0sched или ввод нового
			SELECT tmp_sch
			GO TOP 
			AFIELDS(laFields)
			
			SELECT tmp_sch1
			GO TOP 
			lcStrIzm1=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_sch1.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm1=lcStrIzm1+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
						
			SELECT tmp_sch
			lcStrIzm=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_sch.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
			IF !EMPTY(lcStrIzm1) OR EMPTY(lcStrIzm1) AND !EMPTY(lcStrIzm)
				lcStrIzm1='Прежние значения:'+CHR(13)+lcStrIzm1
			ENDIF
			IF !EMPTY(lcStrIzm) OR EMPTY(lcStrIzm) AND !EMPTY(lcStrIzm)
				lcStrIzm='Новые значения:'+CHR(13)+lcStrIzm
			ENDIF
			IF !EMPTY(lcStrIzm1) OR !EMPTY(lcStrIzm)
				lcStrIzm=lcStrIzm1+lcStrIzm
				INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
										(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0SCHED',lcStrIzm,lcNamec)
			ENDIF 							
		ENDIF
		*
		IF SUBSTR(tcStrKorr,9,1)=='1' OR tnVidOp=1 &&была корректировка f0agr или ввод нового
			SELECT tmp_agr
			GO TOP 
			AFIELDS(laFields)
			
			SELECT tmp_agr1
			GO TOP 
			lcStrIzm1=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_agr1.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm1=lcStrIzm1+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
						
			SELECT tmp_agr
			lcStrIzm=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_agr.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
			IF !EMPTY(lcStrIzm1) OR EMPTY(lcStrIzm1) AND !EMPTY(lcStrIzm)
				lcStrIzm1='Прежние значения:'+CHR(13)+lcStrIzm1
			ENDIF
			IF !EMPTY(lcStrIzm) OR EMPTY(lcStrIzm) AND !EMPTY(lcStrIzm)
				lcStrIzm='Новые значения:'+CHR(13)+lcStrIzm
			ENDIF
			IF !EMPTY(lcStrIzm1) OR !EMPTY(lcStrIzm)
				lcStrIzm=lcStrIzm1+lcStrIzm
				INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
										(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0AGR',lcStrIzm,lcNamec)
			ENDIF 							
		ENDIF 
		*
		IF SUBSTR(tcStrKorr,10,1)=='1' OR tnVidOp=1 &&была корректировка jillink или ввод нового
			SELECT tmp_link
			GO TOP 
			AFIELDS(laFields)
			
			SELECT tmp_link1
			GO TOP 
			lcStrIzm1=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_link1.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm1=lcStrIzm1+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
						
			SELECT tmp_link
			lcStrIzm=''
			lnNz=0
			SCAN 
				lnNz=lnNz+1
				FOR i=1 TO ALEN(laFields,1)
					lcNamRek='tmp_link.'+ALLTRIM(laFields(i,1))
					lcZnach=UNC_TO_STR(&lcNamRek)
					IF !EMPTY(&lcNamRek)
						lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
					ENDIF 
				ENDFOR 
			ENDSCAN
			IF !EMPTY(lcStrIzm1) OR EMPTY(lcStrIzm1) AND !EMPTY(lcStrIzm)
				lcStrIzm1='Прежние значения:'+CHR(13)+lcStrIzm1
			ENDIF
			IF !EMPTY(lcStrIzm) OR EMPTY(lcStrIzm) AND !EMPTY(lcStrIzm)
				lcStrIzm='Новые значения:'+CHR(13)+lcStrIzm
			ENDIF
			IF !EMPTY(lcStrIzm1) OR !EMPTY(lcStrIzm)
				lcStrIzm=lcStrIzm1+lcStrIzm
				INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
										(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'JILLINK',lcStrIzm,lcNamec)
			ENDIF 							
		ENDIF   	   	 
	CASE INLIST(tnVidOp,5)&&удаление карточки дома
		*
		SELECT tmp_sam1
		GO TOP 
		lnKodd=tmp_sam1.koddz
		lnObjid=tmp_sam1.objid
		AFIELDS(laFields)
		lcStrIzm=''
		FOR i=1 TO ALEN(laFields,1)
			lcNamRek='tmp_sam1.'+ALLTRIM(laFields(i,1))
			lcZnach=UNC_TO_STR(&lcNamRek)
			lcStrIzm=lcStrIzm+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
		ENDFOR
		INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
							(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0SAM',lcStrIzm,lcNamec)
		*
		SELECT tmp_vid1
		GO TOP 
		AFIELDS(laFields)
		lcStrIzm=''
		lnNz=0
		SCAN
			lnNz=lnNz+1
			FOR i=1 TO ALEN(laFields,1)
				lcNamRek='tmp_vid1.'+ALLTRIM(laFields(i,1))
				lcZnach=UNC_TO_STR(&lcNamRek)
				lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
			ENDFOR
		ENDSCAN
		INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
							(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0VID',lcStrIzm,lcNamec) 						  					
		*
		SELECT tmp_plat1
		GO TOP 
		AFIELDS(laFields)
		lcStrIzm=''
		lnNz=0
		SCAN
			lnNz=lnNz+1
			FOR i=1 TO ALEN(laFields,1)
				lcNamRek='tmp_plat1.'+ALLTRIM(laFields(i,1))
				lcZnach=UNC_TO_STR(&lcNamRek)
				lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
			ENDFOR
		ENDSCAN
		INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
							(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0PLAT',lcStrIzm,lcNamec)
		*
		SELECT tmp_que1
		GO TOP 
		AFIELDS(laFields)
		lcStrIzm=''
		lnNz=0
		SCAN
			lnNz=lnNz+1
			FOR i=1 TO ALEN(laFields,1)
				lcNamRek='tmp_que1.'+ALLTRIM(laFields(i,1))
				lcZnach=UNC_TO_STR(&lcNamRek)
				lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
			ENDFOR
		ENDSCAN
		INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
							(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0QUEUE',lcStrIzm,lcNamec)
		*
		SELECT tmp_sch1
		GO TOP 
		AFIELDS(laFields)
		lcStrIzm=''
		lnNz=0
		SCAN
			lnNz=lnNz+1
			FOR i=1 TO ALEN(laFields,1)
				lcNamRek='tmp_sch1.'+ALLTRIM(laFields(i,1))
				lcZnach=UNC_TO_STR(&lcNamRek)
				lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
			ENDFOR
		ENDSCAN
		INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
							(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0SCHED',lcStrIzm,lcNamec)
		*
		SELECT tmp_agr1
		GO TOP 
		AFIELDS(laFields)
		lcStrIzm=''
		lnNz=0
		SCAN
			lnNz=lnNz+1
			FOR i=1 TO ALEN(laFields,1)
				lcNamRek='tmp_agr1.'+ALLTRIM(laFields(i,1))
				lcZnach=UNC_TO_STR(&lcNamRek)
				lcStrIzm=lcStrIzm+ALLTRIM(STR(lnNz))+' '+ALLTRIM(laFields(i,1))+' = '+lcZnach+CHR(13)
			ENDFOR
		ENDSCAN
		INSERT INTO samz_izm (objid,nkoddz,tdateop,nkodop,cnamep,cnametab,moldnew,cnamec) VALUES ;
							(lnObjid,lnKodd,ltDateOp,tnVidOp,POLZ_IMA,'F0AGR',lcStrIzm,lcNamec)
ENDCASE  
*
IF llOpen
	USE IN samz_izm
ENDIF 
SELECT (lnSelect)
ENDPROC 

*************************************************************************
* GETPVEDN																*
*************************************************************************
* Процедура получения строки с кодами источников поступлений квартир	*
* на основе справочника видов удержаний									*
*************************************************************************
* Возвращаемое значение:                                     			*
*	(C) - строка с кодами источников поступлений квартир				*
*************************************************************************
* Урбанович В.Г.									         			*
*************************************************************************
PROCEDURE GETPVEDN
LOCAL lcRet,lnSel
lcRet=''
IF USED('f0451')
	lnSel=SELECT()
	SELECT f0451
	SCAN FOR pref=14
		lcRet=lcRet+TRIM(f0451.namd)
	ENDSCAN 
	SELECT (lnSel)
ENDIF 
RETURN lcRet
ENDPROC 


*************************************************************************
* START_PROMPT															*
*************************************************************************
* Процедура автоматического запуска напоминаний							*
*************************************************************************
* Урбанович В.Г. 								18.05.2013				*
*************************************************************************
PROCEDURE START_PROMPT
LOCAL lcInif,lnPromptZapusk
lcInif=INIF_READ('SAMZASTR','PROMPT_ZAPUSK')
lnPromptZapusk=VAL(lcInif)
DO CASE 
	CASE lnPromptZapusk=0&&запуск вручную
		RETURN 
	CASE lnPromptZapusk=1&&запуск один раз в день
		lcInif=INIF_READ('SAMZASTR','PROMPT_DATE')
		IF LEFT(lcInif,5)=='ERROR'
			RETURN 
		ENDIF 
		IF CTOD(lcInif)<DATE()
			DO FORM prompt 
		ENDIF 
	CASE lnPromptZapusk=2&&запуск при каждом вызове комплекса
		DO FORM prompt 
ENDCASE 
ENDPROC

*************************************************************************
* GET_IZMOP																*
*************************************************************************
* Процедура возврата наименования операции из файла изменений по ее		*
* коду																	*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tnKodop (N) - код операции											*
* Возвращаемое значение:                                     			*
*	(C) - наименование операции											*
*************************************************************************
* Урбанович В.Г. 										21.05.2013		*
*************************************************************************
* ИЗМЕНЕНИЯ:															*
*	13.05.2019 (Урбанович В.Г.) - перевод в автономный режим			*
*************************************************************************
PROCEDURE GET_IZMOP
LPARAMETERS tnKodop
LOCAL lcRet
lcRet='Неизвестная операция'
DO case
	CASE tnKodop=1
		lcRet='ввод нового объекта'
	CASE tnKodop=2
		lcRet='ввод нового объекта из БД Жилье'
	CASE tnKodop=3
		lcRet='корректировка объекта'
	CASE tnKodop=4
		lcRet='смена кода объекта'
	CASE tnKodop=5
		lcRet='удаление объекта из БД Самзастройщики'
	CASE tnKodop=6
		lcRet='удаление дома из БД Жилье'
	CASE tnKodop=10
		lcRet='перенос объекта в архив'
	CASE tnKodop=11
		lcRet='извлечение объекта из архива'
	OTHERWISE
		lcRet=ALLTRIM(STR(tnKodop))+' '+lcRet
ENDCASE 
RETURN lcRet
ENDPROC  


*************************************************************************
* OPEN_TABLES															*
*************************************************************************
* Процедура начального открыния необходимого набора таблиц в зависимости*
* от режима работы 														*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tnKodOpen (n) - режим открытия таблиц:								*
*		1 - форма sam_korr												*
*		2 - форма viewdom												*
*		3 - форма zapros												*
*		4 - форма vyhform												*
*		5 - форма prompt												*
*************************************************************************
* Урбанович В.Г.										19.08.2016		*
*************************************************************************
* ИЗМЕНЕНИЯ:															*
*	21.08.2017 (Урбанович В.Г.) - добавление квартир из освобождаемого	*
*		фонда															*
*	29.04.2019 (Урбанович В.Г.) - перевод в автономный режим			*
*************************************************************************
PROCEDURE OPEN_TABLES
LPARAMETERS tnKOdOpen
LOCAL lnTryErr
LOCAL loExc as Exception
lnTryErr=0 
TRY 
	IF INLIST(tnKodOpen,1,2,3,4,5)
		USE (ADDBS(p_spr)+'F0451') IN 0 AGAIN ALIAS f0451
		USE (ADDBS(p_spr)+'F0453') IN 0 AGAIN ALIAS f0453
		USE (ADDBS(p_spr)+'F0JSK') IN 0 AGAIN ALIAS f0jsk
		USE (ADDBS(p_spr)+'F0456') IN 0 AGAIN ALIAS f0456
		USE (ADDBS(p_spr)+'FSER') IN 0 AGAIN ALIAS fser
		USE (ADDBS(p_spr)+'FMKR1') IN 0 AGAIN ALIAS fmkr1
		USE (ADDBS(p_spr)+'F0454') IN 0 AGAIN ALIAS f0454
		USE (ADDBS(p_spr)+'FPVEDN') IN 0 AGAIN ALIAS fpvedn
		USE (ADDBS(p_spr)+'FVED') IN 0 AGAIN ALIAS fved
		USE (ADDBS(p_spr)+'F0458') IN 0 AGAIN ALIAS f0458
		USE (ADDBS(p_spr)+'F0459') IN 0 AGAIN ALIAS f0459
		USE (ADDBS(p_spr)+'F0460') IN 0 AGAIN ALIAS f0460
		USE (ADDBS(p_spr)+'F0KSD') IN 0 AGAIN ALIAS f0ksd
		*
		USE (ADDBS(p_sam)+'F0SAM') IN 0 AGAIN ALIAS f0sam
		USE (ADDBS(p_sam)+'F0VID') IN 0 AGAIN ALIAS f0vid
		USE (ADDBS(p_sam)+'F0PLAT') IN 0 AGAIN ALIAS f0plat
		USE (ADDBS(p_sam)+'F0ID') IN 0 AGAIN ALIAS f0id
		USE (ADDBS(p_sam)+'F0QUEUE') IN 0 AGAIN ALIAS f0queue
		USE (ADDBS(p_sam)+'F0SCHED') IN 0 AGAIN ALIAS f0sched
		USE (ADDBS(p_sam)+'SAMZ_IZM') IN 0 AGAIN ALIAS samz_izm
		USE (ADDBS(p_sam)+'F0SLUINF') IN 0 AGAIN ALIAS f0sluinf
		USE (ADDBS(p_sam)+'JILLINK') IN 0 AGAIN ALIAS jillink
		USE (ADDBS(p_sam)+'F0AGR') IN 0 AGAIN ALIAS f0agr
		USE (ADDBS(p_sam)+'DOCATT') IN 0 AGAIN ALIAS docatt
		*
		USE (ADDBS(p_dat)+'FOBN') IN 0 again ALIAS NEWFOBN
		USE (ADDBS(p_dat)+'FNOV') IN 0 AGAIN ALIAS fnov
		USE (ADDBS(p_dat)+'A0NOV') IN 0 AGAIN ALIAS a0nov
		USE (ADDBS(p_dat)+'FOSV') IN 0 AGAIN ALIAS fosv
		USE (ADDBS(p_dat)+'A0OSV') IN 0 AGAIN ALIAS a0osv
		IF FSIZE('zadom','fnov')=6
			gnCorrectZadom=10000000
		ELSE
			gnCorrectZadom=0
		ENDIF 
	ENDIF
	USE (ADDBS(p_dat)+'F0SVED') IN 0 AGAIN ALIAS f0sved 
	IF tnKodOpen=4
		USE (ADDBS(path_data)+'F0POLZ') IN 0 AGAIN ALIAS f0polz
	ENDIF  
CATCH TO loExc 
	lnTryErr=1
	SAMERROR(loExc.ErrorNo,loExc.Procedure+' ('+PROGRAM()+')',;
		loExc.LineNo,loExc.Message,loExc.LineContents,'T')
ENDTRY
IF lnTryErr=1 	 
	msg('База данных отсутствует или недоступна'+CHR(13)+CHR(13)+;
		'Проверьте правильно ли указаны пути к базам данных',;
		'OK','stop','Внимание',color_err,',,B')
	RETURN .f.
ENDIF 	
ENDPROC 


*************************************************************************
* NEW_ID																*
*************************************************************************
* Процедура формирования нового значения идентификатора					*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tcNameTab (C) - имя идентификатора, для которого формируется новое  *
*					значение											*
* Возвращаемое значение:                                     			*
*	(N) - новое значение идентификатора									*
*************************************************************************
* Урбанович В.Г. 								22.08.2016				*
*************************************************************************
PROCEDURE NEW_ID
	LPARAMETERS tcNameTab
	LOCAL lnNewNom
	SELECT f0id
	LOCATE FOR ALLTRIM(nametab)==tcNameTab
	IF !FOUND()
		INSERT INTO f0id (nametab) VALUES (tcNameTab)
	ENDIF 
	IF RLOCK()
		lnNewNom=f0id.newid+1
		replace f0id.newid WITH lnNewNom IN f0id
		IF CURSORGETPROP("Buffering",'f0id')>1
			TABLEUPDATE(0,.f.,'f0id')
		ENDIF 
		UNLOCK IN f0id
		RETURN lnNewNom
	ELSE
		RETURN .f.
	ENDIF
ENDPROC 

*************************************************************************
* COUNTPLO																*
*************************************************************************
* Процедура расчета передаваемой площади								*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tnPlof (N) - фактическая общая площадь								*
*	tnPplosh (N) - планируемая общая площадь							*
*	tnPlogos (N) - площадь, построенная для нуждающихся с господдержкой	*
*	tnProc (N) - процент удержания										*
*	tnPloud (N) - площадь удержания										*
*	tnPloots (N) - площадь, затраченная на отселение					*
*	tnFlcount (N) - признак формулы расчета								*
*	tnCalcend (N) - признак окончательный расчет произведен				*
*	tcRelBase (C) - основаниедля освобождения от УПС					*
* Возвращаемое значение:                                     			*
*	(N) - расчитанная площадь, подлежащая передаче						*
*************************************************************************
* Урбанович В.Г. 								05.09.2016				*
*************************************************************************
* ИЗМЕНЕНИЯ:															*
*	08.07.2020 (Урбанович В.Г.) - добавление новой формулы расчета		*
*					с 01.01.2019 (ред. от 11.12.2018 № 892 с измен.)	*
*************************************************************************
PROCEDURE COUNTPLO
LPARAMETERS tnPlof,tnPplosh,tnPlogos,tnProc,tnPloud,tnPloots,tnFlcount,tnCalcend,tcRelBase
LOCAL lnSo,lnSumPlo
STORE 0 TO lnSo,lnSumPlo
*общая площадь
IF tnFlcount=3
	lnSo=tnPplosh
ELSE 
	IF !EMPTY(tnPlof)
		lnSo=tnPlof
	ELSE
		lnSo=tnPplosh
	ENDIF
ENDIF  
*отнимаем площадь, построенную с господдержкой
lnSo=lnSo-tnPlogos
*определяем площадь, подлежащую удержанию
IF !EMPTY(tnProc)
	IF INLIST(tnFlcount,2,3)
		lnSumPlo=ROUND((lnSo*tnProc/100)/(1+tnProc/100),2)
	ELSE
		lnSumPlo=ROUND(lnSo*tnProc/100,2)
	ENDIF 
ELSE
	IF !EMPTY(tnPloud)
		lnSumPlo=tnPloud
	ENDIF 
ENDIF 
*отнимаем площадь, затраченную на отселение
lnSumPlo=lnSumPlo-tnPloots
IF tnCalcend=1 OR !EMPTY(tcRelBase)
	lnSumPlo=0
ENDIF 
RETURN lnSumPlo
ENDPROC

*************************************************************************
* COUNTPLO_UPS															*
*************************************************************************
* Процедура расчета передаваемой площади и формирования строки расчета	*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tnFlcount (N) - признак формулы расчета								*
*					0 или 1 - S=УП*(Sобщ-Sгос):100-Sотс					*
*					2 - S=((Sобщ-Sгос)*УП:100/(1+УП:100))-Sотс			*
*					3 - S=((Sобщ.псд-Sгос)*УП:100/(1+УП:100))-Sотс		*
*	tnPlof (N) - фактическая общая площадь								*
*	tnPplosh (N) - планируемая общая площадь							*
*	tnPlogos (N) - площадь, построенная для нуждающихся с господдержкой	*
*					(компенсация УПС не производится)					*
*	tnProc (N) - процент удержания										*
*	tnPloud (N) - площадь удержания										*
*	tnPloots (N) - площадь, затраченная на отселение					*
*	tnCalcend (N) - признак окончательный расчет произведен				*
*	tcRelBase (C) - основание для освобождения от УПС					*
* Возвращаемое значение:                                     			*
*	(O) - объект custom содержащий расчитанную площадь и строку расчета *
*			.ploups - расчитанная площадь								*
*			.strcount - строка расчета									*
*************************************************************************
* Урбанович В.Г. 								09.07.2020				*
*************************************************************************
PROCEDURE COUNTPLO_UPS
LPARAMETERS tnFlcount,tnPlof,tnPplosh,tnPlogos,tnProc,tnPloud,tnPloots,tnCalcend,tcRelBase
LOCAL lnSo,lnSumPlo,loRet,lnPlostr
STORE 0 TO lnSo,lnSumPlo,lnPlostr
*возвращаемый объект
loRet=CREATEOBJECT('custom')
loRet.addproperty('ploups',0)
loRet.addproperty('strcount','')
*общая площадь
IF tnFlcount=3 OR EMPTY(tnPlof)
	lnSo=tnPplosh
ELSE 
	lnSo=tnPlof
ENDIF
*определяем площадь, подлежащую удержанию
IF EMPTY(lnSo) OR (EMPTY(tnPloud) AND EMPTY(tnProc)) &&не заполнены обязательные поля (не хватает данных)
	loRet.ploups=0
	loRet.strcount='не хватает данных для расчета'
ELSE	
	IF !EMPTY(tnProc)
		IF INLIST(tnFlcount,2,3)
			lnSumPlo=ROUND(((lnSo-tnPlogos)*tnProc/100)/(1+tnProc/100)-tnPloots,2)
			IF EMPTY(tcRelBase)
				lnPlostr=lnSumPlo
			ENDIF
			loRet.strcount=ALLTRIM(STR(lnPlostr,10,2))+'=(('+ALLTRIM(STR(lnSo,10,2))+CHR(150)+;
				ALLTRIM(STR(tnPlogos,10,2))+')'+CHR(149)+ALLTRIM(STR(tnProc,10,2))+;
				':100/(1+'+ALLTRIM(STR(tnProc,10,2))+':100))'+CHR(150)+ALLTRIM(STR(tnPloots,10,2)) 
		ELSE
			lnSumPlo=ROUND((lnSo-tnPlogos)*tnProc/100-tnPloots,2)
			IF EMPTY(tcRelBase)
				lnPlostr=lnSumPlo
			ENDIF
			loRet.strcount=ALLTRIM(STR(lnPlostr,10,2))+'='+ALLTRIM(STR(tnProc,10,2))+CHR(149)+'('+ALLTRIM(STR(lnSo,10,2))+;
				CHR(150)+ALLTRIM(STR(tnPlogos,10,2))+'):100'+chr(150)+ALLTRIM(STR(tnPloots,10,2))
		ENDIF 
	ELSE
		IF !EMPTY(tnPloud)
			lnSumPlo=tnPloud-tnPloots
			IF EMPTY(tcRelBase)
				lnPlostr=lnSumPlo
			ENDIF
			loRet.strcount=ALLTRIM(STR(lnPlostr,10,2))+'='+ALLTRIM(STR(tnPloud,10,2))+chr(150)+ALLTRIM(STR(tnPloots,10,2))
		ENDIF 
	ENDIF
ENDIF 
*
IF tnCalcend=1 OR !EMPTY(tcRelBase)
	lnSumPlo=0
ENDIF 
loRet.ploups=lnSumPlo
RETURN loRet
ENDPROC  


*************************************************************************
* GETACTION																*
*************************************************************************
* Процедура формирования имени действия для графика ввода очереди ввода *
*************************************************************************
* Принимаемые параметры: 							         			*
*	tnAction (N) - код действия											*
* Возвращаемое значение:                                     			*
*	(С) - строка с именем												*
*************************************************************************
* Урбанович В.Г. 								19.10.2016				*
*************************************************************************
PROCEDURE GETACTION
LPARAMETERS tnAction
LOCAL lcRet
lcRet=''
DO CASE 
	CASE tnAction=1
		lcRet='Начало строительства'
	CASE tnAction=2
		lcRet='Плановый ввод'
	CASE tnAction=3
		lcRet='Перенос плановой даты ввода'
	CASE tnAction=4
		lcRet='Фактический ввод'
	CASE tnAction=5
		lcRet='Заселение'
ENDCASE 
RETURN lcRet
ENDPROC 


*************************************************************************
* GETQUART																*
*************************************************************************
* Процедура возврата из даты срока исполнения в виде "1 квартал 2008"	*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tdDate (D) - дата													*
* Возвращаемое значение:                                     			*
*	(с) - сформированная строка											*
*************************************************************************
* Урбанович В.Г. 								25.10.2016				*
*************************************************************************
PROCEDURE GETQUART
LPARAMETERS tdDate
LOCAL lcRet
lcRet=ALLTRIM(STR(QUARTER(tdDate)))+' квартал '+ALLTRIM(STR(YEAR(tdDate)))
RETURN lcRet
ENDPROC 

*************************************************************************
* GETNAMESER															*
*************************************************************************
* Процедура возврата названия серии объекта по ее коду					*
*************************************************************************
* Принимаемые параметры: 							         			*
*	tnKodSer (N) - код серии объкта										*
* Возвращаемое значение:                                     			*
*	(C) - название серии объекта										*
*************************************************************************
* Урбанович В.Г. 								12.06.2019				*
*************************************************************************
PROCEDURE GETNAMESER
LPARAMETERS tnKodSer
LOCAL lcRet
lcRet=SPACE(6)
IF SEEK(tnKodSer,'fser','fser')
	lcRet=fser.naim
ENDIF 
RETURN lcRet
ENDPROC 


