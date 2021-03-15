?'Нажмите клавишу дя того, чтобы узнать ее код'
?'ESC-выход'
do while .t.
	a=inkey(0)
	?a
	if a=27
		?'Конец работы keycode'
		exit
	endif	
enddo