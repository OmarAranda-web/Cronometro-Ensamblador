__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC ;La configuracion de como va ocilar el pic 
LIST P=PIC16F84A				;El microcontrolador usando es el pic16f84A

	#INCLUDE <P16F84A.INC>		;BIBLIOTECA
	ORG		0					;La direccion de memoria donde va iniciar el programa 
;Se declaran nombres a 4 registros de uso general, estos se encontranran en la posicion de memoria de 0x0C hasta 0x68 hexadecimal
	CBLOCK 0x0C		;Se abre el bloque de registros que vamos a ocupar y nombrar iniciando desde la posicion 0x0C
		reg1		;0x0C Este registro nos servira para colocarle un numero que nos servira para la realizacion de un ciclo anidado que permitira mostrar cierto tiempo los numeros
		reg2		;0x0D Al igual que el anterior nos servira para colocar cierta cantidad para un ciclo anidado 
		reg3		;0x0E Y este tambien servira para el ciclo anidado
		min1		;0x0F Esta variable nos servira para guardar los valores del digito 1 de los minutos del reloj
		min2		;0x10 Esta segunda variable llamada min2, nos servira para guardar el valor del digito 2 de los minutos del reloj
		hor1		;0x11 Esta tercera variable llamada hor1, nos servira para guardar el valor del digito 3 que pertenece a la hora 1 al 9 del reloj
		hor2		;0x12 Esta cuarta variable llamada hor2, nos permitira guardar el cuarto y ultimo digito del reloj que pertence al segundo digito de las horas
		dos			;0x13 Apartir de esta variable las ocuparemos para condicionar los saltos para reiniciar el numero cuando llegue a cierto valor limite del reloj
		cuatro		;0x14 Esta variable se utilizara para mandar el reseteo cuando llegue a 24 horas el reloj el cual ya habra pasado un dia 
		seis		;0x15 Esta variable se utilizara para cuando los 2 digitos de los minutos lleguen a 60 se resete ya que ya habra pasado una hora
		diez		;0x16 Esta ultima variable sera utilizada para cuando uno de los digitos llegue a 9 y haga el cambio a 10 para vuelva a iniciar desde 0
	ENDC			;Termina la declaracion de registros de CBLOCK

;Configuracion de puertos
	bsf		STATUS, RP0		;Acceso al banco 1 de la memoria de datos.
	movlw	b'00000001' 	;Los este numero en binario y lo movemos al registro de trabajo w
	movwf	TRISA			;Configura el Puerto A con una entrada ya que sera la que nos servira para iniciar el reloj.
	clrf	TRISB			;Configura el Puerto B como salidas.
	bcf		STATUS, RP0		;Acceso al banco 0 de la memoria de datos.
;Programa principal:

inicio
	;minutos1
		movlw	0x00		;Moveremos un cero hexadecimal al registro de trebajo
		movwf	min1		;Y este lo moveremos al registro min1 declarado en el cblock
	;minutos2
		movlw	0x00		;Moveremos un cero hexadecimal al registro de trebajo
		movwf	min2		;Y este lo moveremos al registro min2 declarado en el cblock
	
	;hora1
		movlw	0x00		;Moveremos un cero hexadecimal al registro de trebajo
		movwf	hor1		;Y este lo moveremos al registro min1 declarado en el cblock
	
	;hora2
		movlw	0x00		;Moveremos un cero hexadecimal al registro de trebajo
		movwf	hor2		;Y este lo moveremos al registro min1 declarado en el cblock
		
		
		movlw	b'11110000'		;Mandaremos Este numero al puerto b para resetear cualquier inconceniente en los pines del puerto b
		movwf	PORTB			;Movemos dicho numero del registro de trabajo al puerto B

;Apartir de este punto hasta la linea btfss PORTA,0 - Esto mandara a encerder con un cero todos los catodos con un cero hasta que mandemos la señal de avanzar.
		movf	min1,w			;Por lo que el valor que tenga uno pasara al registro de trabajo 
		andlw	b'00001111'		;Verificamos que los numeros que se mande sean solamente del 0 al 9 con los primero 4 bits en binario
		call	tabla1			;Mandamos a llamar a la tabla 1
		movwf	PORTB			;Mandamos el numero que nos regrese la tabla 1 al portB
		
		;Repetimos el proceso con los demas catodos del reloj solo que cada una tendra su correspondiente tabla
		movf	min2,w
		andlw	b'00001111'		
		call	tabla2
		movwf	PORTB
	
		movf	hor1,w
		andlw	b'00001111'		
		call	tabla3
		movwf	PORTB
	
		movf	hor2,w
		andlw	b'00001111'		
		call	tabla4
		movwf	PORTB
		
		
	
	btfss	PORTA,0				;Esta accion lo que hara es verificar si se ha mandado una señal en el puerto 0 del regitro A 
	goto	sinpresionar		;En caso de que sea distinto de 0 se ejecutara el salto a la etiqueta sinpresionar
	goto	conteo1				;En caso de que se mande la señal se saltara la linea anterio y seguira en conteo1

conteo1
	movlw	0x15			;W se carga con el numero 74h(comienza la llamada)
	movwf	reg3			;Se pasa a reg3
externo
	movlw	0x15			;W se carga con el numero 73h
	movwf	reg2			;Se pasa a reg2
mitad
	movlw	0x15			;W se carga con el numero 74h
	movwf	reg1			;Se pasa a reg1
;Entre los tres numeros anteriores se forma un minuto en tiempo real.
interno

;En estas lineas a continuacion se repetira el mismo proceso que arriba solo que esta vez no esta condicioandado ya que apartir de coneteo1 se repetira el proceso cada 60 segundos.
		movf	min1,w			;Por lo que el valor que tenga uno pasara al registro de trabajo 
		andlw	b'00001111'		;Verificamos que los numeros que se mande sean solamente del 0 al 9 con los primero 4 bits en binario
		call	tabla1			;Mandamos a llamar a la tabla 1
		movwf	PORTB			;Mandamos el numero que nos regrese la tabla 1 al portB
		
		movf	min2,w
		andlw	b'00001111'		
		call	tabla2
		movwf	PORTB
	
		movf	hor1,w
		andlw	b'00001111'		
		call	tabla3
		movwf	PORTB
	
		movf	hor2,w
		andlw	b'00001111'		
		call	tabla4
		movwf	PORTB
		
		btfss	PORTA,0			;Solo que esta linea de codigo solo servira en caso de que se dese para el reloj en cierta hora.
		goto	interno			;En caso de que sea distinto de 0 se ejecutara el salto a la etiqueta primero 
		
	decfsz	reg1,1			;Le resta una unidad a reg1
	goto	interno			;Sigue decrementando hasta que reg1 llegue a 0
	decfsz	reg2,1			;Le resta una unidad a reg2
	goto	mitad			;Sigue decrementando hasta que reg2 llegue a 0
	decfsz	reg3,1			;Le resta una unidad a reg3
	goto	externo			;Sigue decrementando hasta que reg3 llegue a 0
	
;Apartir de aqui se daran los incrementos en los digitos y las condiciones para reiniciar dicho digito 
	movlw	d'11'		;Declaraemos un 11 decimal y lo moveremos al registro de treabajo
	movwf	diez		;Y el 11 anteriormente declarado lo moveremos a la variable diez, que nos servira para comparar cuando un numero llegue a 10
	incf	min1		;Hacemos el incremento en 1 en min1 
	movfw	min1		;Copiamos la variable min1 al regitro de treabajo
	subwf	diez		;restamos lo que hay en el regitro de treabajo con diez y dicho resultado lo guardaremos en diez
	decfsz	diez,1		;Si el resultado de dicha resta fue uno quiere decir que min1 ya llego a 10 por lo que al decrementar la variable diez nos dara un resultado de 0 entonces saltara la linea que sigue
	goto	conteo1		;En caso de que min9 sea menora a 10 mandara dicho numero a visualizarse al catodo
	goto	cambios1	;En caso de que min1 llegue con un valor de 10 realizara un salto a la rutina cambios 1, el cual se encargara de reiniciar la variable min1 con un cero y hara el incremento en la 
						;variable min2
;Subrutina para incrementar min2, reiniciar min1, condicionar el cambio para hor1
cambios1
		clrf	min1	;Limpiamos lo que tenga la variable min1
		movlw	d'7'	;Mandamos un 7 decimal al regitro de treajo que nos servira para ver cuando el catodo 2 llegue a 6 se reinicie ya que ya habra pasado 1 hora 
		movwf	seis	;Mandamos el 7 del registro de trabajo a la variable seis para la resta que nos determinara si min2 llego a 6
		incf	min2	;Hacemos el incremento en min2
		movfw	min2	;Movemos y copiamos lo que tenga min2 al registro de trabajo 
		subwf	seis	;Realizamos la resta de lo que tenga el registro de trabajo con el valor que tenga seis, y el resultado de dicha resta se guardara en seis
		decfsz	seis,1	;Si el decremento es 0 realizara un salto al goto cambios2, en caso de ser 1 o mayor, no realizara el salto, por lo que volvera a conteo1
		goto	conteo1	;Salto a conteo1
		goto	cambios2	;Salto a cambios2
;En caso de que min2 llegue a 6 se realizara la siguiente subrutina que sera el cambios2, ya que esta se encargara de incrementar la hora 1 en 1, en caso de que los minutos lleguen a 60
cambios2
		clrf	min2	;Por lo que min2 se limpiara
		movlw	d'11'	;Se declara un 11 en el regitro de trabajo y se guardara en el registro de trabajo
		movwf	diez	;Y lo que tenga el registro de trabajo se guardara en la variable diez
		
	;Se repite el proceso anterior solo que con el valor de 4 y la variable cuatro
		movlw	d'4'
		movwf	cuatro
	;Se repite el proceso anterior solo que con la variable dos y se le asignara un valor de 3	
		movlw	d'3'
		movwf	dos
	;Los pasos anteriores nos serviran para condicionar 3 cosas, la primera cuando el catodo de la hora 1 llegue a 10, ya que abarcara 2 digitos, y cuando haya pasado las 20 horas ya que apartir de hay
	;ya solo seria cuatro, y de hay hacer un reseteo total, ya que habra pasado un dia.
		movfw	hor2	;Moveremos la hora2 al registro de trabajo
		subwf	dos		;Restamos el registro de trabajo con el valor de dos y lo guardamos en dos
		decfsz	dos,1	;Si dos lo decrementamos en 1 y el resultado es 0, detectara que ya estan en las horas 20, si no mandara a la subrutina continuar el cual trabajara de manera normal.
		goto	continuar	;Salta a continuar
		goto	detectar	;Salra a detectar
;En caso de que este el reloj en las 20 horas se ejecutara la siguiente subrutina que se encargara de ver si se ha llegado a las 24 horas, para resetear tdoas las variables
detectar
		movfw	hor1		;movemos lo que tenga hor1 al registro de trabajo
		subwf	cuatro		;Restamos lo que tenga el registro de trabajo con cuatro y se guardara en cuatro
		decfsz	cuatro,1	;Si lo que tenga cuatro el decremento es 0, detectara que ya son 24 horas y mandara a llamar a la subrutina reseteo que limpiara las variables min1,min2, hor1 y hor2
		goto	continuar	;Salta a continuar en caso de que no se haya llegado a al hora 24
		goto	reseteo		;Sino reseteara las variables.
;Esta subrutina se encargara de incrementar el catodo 1 de las horas hasta llegar a nueve 
continuar
		incf	hor1		;Incrementa a 1 hor1
		movfw	hor1		;Movemos lo que tenga hor1 al registro de trabajo
		subwf	diez		;Restamos el registro de trabajo con diez, y el resultado se guarda en 10 
		decfsz	diez,1		;En caso de que el decremento de la variable diez sea cero pasara a la subrutina cambios 3 ya que ya se habra llegado a la hora 10, en caso de que no se pasara a conteo1
		goto	conteo1		;Salto a conteo1
		goto	cambios3	;Salto a cambios 3
;Esta subrutina se ejecutara cuando se llegue a la hora diez para en el ultimo catodo muestre el 1 de las horas 10 y el 2 de las horas 20
cambios3
		clrf	hor1		;Limpiamos la variable hor1
		movlw	d'4'		;Declaramos un 4 decimal en el registro de trabajo
		movwf	dos			;Lo movemos a la variable dos
		incf	hor2		;Incrementamos la hor2 en 1 
		movfw	hor2		;Lo que tenga hor1 lo movemos al registro de trabajo 
		subwf	dos			;Restamos lo que tenga el registro de trabajo menos la variable dos, y se guardara en 2
		decfsz	dos,1		;En caso de que el decremento de dos tenga como resultado 0 pasara a cambios 4 sino a conteo1
		goto	conteo1		;Salto conteo1
		goto	cambios4	;Salto cambios4
;Esta subrutina solo se dara cuando haya pasado arriba de las 24 horas
cambios4
		clrf	hor2
		goto	conteo1
;Y se aplicara reseteo cuando pase de 34 horas y hara un salto a conteo 1 para iniciar todo de nuevo
reseteo
		clrf	min1
		clrf	min2
		clrf	hor1
		clrf	hor2
		goto	conteo1
	;cuando lleguea a nueve min1
;Tablas con los datos que se mostraran en los catodos corresponidentes
tabla1
	addwf	PCL, F			;Suma PCL + W para obtener el valor de la tabla
	
	retlw	b'00010000'		;Valor de slaida para la entrada 0000 = 0
	retlw	b'00010001'		;Valor de slaida para la entrada 0001 = 1
	retlw	b'00010010'		;Valor de slaida para la entrada 0010 = 2
	retlw	b'00010011'		;Valor de slaida para la entrada 0011 = 3
	retlw	b'00010100'		;Valor de slaida para la entrada 0100 = 4
	retlw	b'00010101'		;Valor de slaida para la entrada 0101 = 5
	retlw	b'00010110'		;Valor de slaida para la entrada 0110 = 6
	retlw	b'00010111'		;Valor de slaida para la entrada 0111 = 7
	retlw	b'00011000'		;Valor de slaida para la entrada 1000 = 8
	retlw	b'00011001'		;Valor de slaida para la entrada 1001 = 9

tabla2
	addwf	PCL, F			;Suma PCL + W para obtener el valor de la tabla
	
	retlw	b'00100000'		;Valor de slaida para la entrada 0000 = 0
	retlw	b'00100001'		;Valor de slaida para la entrada 0001 = 1
	retlw	b'00100010'		;Valor de slaida para la entrada 0010 = 2
	retlw	b'00100011'		;Valor de slaida para la entrada 0011 = 3
	retlw	b'00100100'		;Valor de slaida para la entrada 0100 = 4
	retlw	b'00100101'		;Valor de slaida para la entrada 0101 = 5

tabla3
	addwf	PCL, F			;Suma PCL + W para obtener el valor de la tabla
	
	retlw	b'01000000'		;Valor de slaida para la entrada 0000 = 0
	retlw	b'01000001'		;Valor de slaida para la entrada 0001 = 1
	retlw	b'01000010'		;Valor de slaida para la entrada 0010 = 2
	retlw	b'01000011'		;Valor de slaida para la entrada 0011 = 3
	retlw	b'01000100'		;Valor de slaida para la entrada 0100 = 4
	retlw	b'01000101'		;Valor de slaida para la entrada 0101 = 5
	retlw	b'01000110'		;Valor de slaida para la entrada 0110 = 6
	retlw	b'01000111'		;Valor de slaida para la entrada 0111 = 7
	retlw	b'01001000'		;Valor de slaida para la entrada 1000 = 8
	retlw	b'01001001'		;Valor de slaida para la entrada 1001 = 9
tabla4
	addwf	PCL, F			;Suma PCL + W para obtener el valor de la tabla
	
	retlw	b'10000000'		;Valor de slaida para la entrada 0000 = 0
	retlw	b'10000001'		;Valor de slaida para la entrada 0001 = 1
	retlw	b'10000010'		;Valor de slaida para la entrada 0010 = 2


	
sinpresionar
	goto inicio ;Realizara un salto a inicio



	END				;Fin del código, esta directiva es obligatoria
