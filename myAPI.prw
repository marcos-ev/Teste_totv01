#Include 'Protheus.ch'
#Include 'RestFul.ch'
#Include "Totvs.ch"
#Include "RwMake.ch"
#Include "FwMvcDef.ch"
#include "fileio.ch"

/*/{Protheus.doc} Webservice myAPI
    Fonte utilizado para testes e treinamentos. 
    Este documento � de propriedade da TOTVS. Todos os direitos reservados.

    IMPORTANTE: Para avalia��o, preencha todos os blocos de coment�rios de 
    acordo com a descri��o inserida.

    @type  Webservice
    @author gabriel.antonio@totvs.com.br 
    /*/ 

WSRESTFUL myAPI DESCRIPTION "Lancamentos (AKD)"

	WSMETHOD POST DESCRIPTION "Inclui lancamentos" WSSYNTAX ""
    //****************************************************************
    /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
    
        Este bloco define um servi�o web denominado myAPI, que trata de lan�amentos de dados do tipo AKD. 
        O m�todo POST � configurado para aceitar requisi��es de inclus�o de lan�amentos.
    */
    //****************************************************************
END WSRESTFUL 

WSMETHOD POST WSSERVICE myAPI
	Local cJSON         := ::GetContent()
	Local oAKD          := JsonObject():New()
	Local oAKDRet
	Local aArea         := GetArea()
	Local aAreaAKD      := AKD->(GetArea())
	Local cMsgAux       := ""
	Local lRet          := .T.
	Local cChavePesq    := ""
	Local nFor          := 0
    Local _clote        := ""
    Local _cID          := 0
    Local aAKDRet       := {} 

	fStrDatHor("Metodo POST requisitado")
    //****************************************************************
    /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
    
            Este bloco trata da execu��o do m�todo POST, recebendo e processando os dados enviados na requisi��o.

    */
    //****************************************************************

	::SetContentType("application/json")
    //****************************************************************
    /* Com o seu conhecimento, descreva a utiliza��o/finalidade da fun��o acima:  

            Define o tipo de conte�do que ser� retornado na resposta da requisi��o como JSON.

    */
    //****************************************************************

	If ValType(cJSON) == "C" .AND. !Empty(cJSON)      

		oAKD:fromJson(cJSON)
 
        DbSelectArea("AK5")
        AK5->(DbSetOrder(1))

        DbSelectArea("AL2")
        AL2->(DbSetOrder(1))

        DbSelectArea("CTT")
        CTT->(DbSetOrder(1))

        DbSelectArea("CTD")
        CTD->(DbSetOrder(1))

        DbSelectArea("CTH")
        CTH->(DbSetOrder(1))

        DbSelectArea("AK6")
        AK6->(DbSetOrder(1))

        DbSelectARea("AKD")
        AKD->(DbSetOrder(1))

        //****************************************************************
        /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
        
                Este bloco realiza a sele��o das �reas de trabalho e a configura��o da ordem de �ndices em algumas tabelas do banco de dados.

        */
        //****************************************************************

        For nFor := 1 to Len(oAKD:AAKD)	
        
            AADD( aAKDRet, JsonObject():new() )
            _nX := len(aAKDRet)
            aAKDRet[_nX][ 'Indice' ]   := cValToChar(nFor)

            //****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            
            Neste trecho, estamos iterando sobre os elementos contidos no array oAKD:AAKD.
            
             For nFor := 1 to Len(oAKD:AAKD)': Este loop percorre todos os elementos do array.

             AADD( aAKDRet, JsonObject():new() )': Aqui, estamos adicionando um novo objeto JSON ao array aAKDRet.

            _nX := len(aAKDRet)': Calcula o comprimento atual do array aAKDRet.

            'aAKDRet[_nX][ 'Indice' ]   := cValToChar(nFor)': Atribui ao �ndice 'Indice' do �ltimo elemento do array o valor do loop convertido para caracter.

            */
            //****************************************************************

            BEGIN SEQUENCE 
 
                _cFilial := oAKD:AAKD[nFor]:AKD_FILIAL
                If Empty(_cFilial)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor do campo AKD_FILIAL nao informado."
                    Break
                EndIf

                cChavePesq := "01"+_cFilial
                If SM0->(msSeek(cChavePesq))
                    U_fGoEmp("01",_cFilial)
                Else
                    aAKDRet[_nX][ 'mensagem' ] := "Filial nao encontrada com a chave " + cChavePesq
                    Break
                EndIf

                cData := oAKD:AAKD[nFor]:AKD_DATA
                If Empty(cData)
                    aAKDRet[_nX][ 'mensagem' ] := "O campo AKD_DATA e obrigatorio e deve estar no formato DD/MM/AAAA."
                    Break
                EndIf

                cHist := oAKD:AAKD[nFor]:AKD_HIST
                If Empty(cHist)
                    aAKDRet[_nX][ 'mensagem' ] := "O campo AKD_HIST e obrigatorio."
                    Break
                EndIf

                nValor := oAKD:AAKD[nFor]:AKD_VALOR1
                If Empty(nValor)
                    aAKDRet[_nX][ 'mensagem' ] := "O campo AKD_VALOR1 e obrigatorio e deve estar no formato float."
                    Break
                EndIf

                cTipo := oAKD:AAKD[nFor]:AKD_TIPO
                If !cTipo $ "1|2|3" .Or. Empty(cTipo)
                    aAKDRet[_nX][ 'mensagem' ] := "Valores aceitos para o campo AKD_TIPO: 1, 2 ou 3."
                    Break
                EndIf

                cConta := padr(oAKD:AAKD[nFor]:AKD_CO,TamSX3("AKD_CO")[1])
                If !AK5->(msSeek(xFilial("AK5")+cConta)) .Or. Empty(cConta)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cConta) + " do campo AKD_CO vazio ou nao encontrado na tabela AK5. "
                    Break
                EndIf

                If AK5->AK5_MSBLQL == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cConta) + " do campo AKD_CO bloqueado na tabela AK5."
                    Break
                EndIf

                cTpSld := padr(oAKD:AAKD[nFor]:AKD_TPSALD,TamSX3("AKD_TPSALD")[1])
                If !AL2->(msSeek(xFilial("AL2")+cTpSld)) .Or. Empty(cTpSld)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cTpSld) + " do campo AKD_TPSALD vazio ou nao encontrado na tabela AL2. "
                    Break
                EndIf

                cCC := padr(oAKD:AAKD[nFor]:AKD_CC,TamSX3("AKD_CC")[1])
                If !CTT->(msSeek(xFilial("CTT")+cCC)) .Or. Empty(cCC)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCC) + " do campo AKD_CC vazio ou nao encontrado na tabela CTT."
                    Break
                EndIf

                If CTT->CTT_BLOQ == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCC) + " do campo AKD_CC bloqueado na tabela CTT."
                    Break
                EndIf

                cITCTB := padr(oAKD:AAKD[nFor]:AKD_ITCTB,TamSX3("AKD_ITCTB")[1]) 
                If !CTD->(msSeek(xFilial("CTD")+cITCTB)) .and. !Empty(cITCTB)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cITCTB) + " do campo AKD_ITCTB nao encontrado na tabela CTD."
                    Break
                EndIf

                If CTD->CTD_BLOQ == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cITCTB) + " do campo AKD_ITCTB bloqueado na tabela CTD."
                    Break
                EndIf

                cCLVLR := padr(oAKD:AAKD[nFor]:AKD_CLVLR,TamSX3("AKD_CLVLR")[1])
                If !CTH->(msSeek(xFilial("CTH")+cCLVLR)) .and. !Empty(cCLVLR)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCLVLR) + " do campo AKD_CLVLR vazio ou nao encontrado na tabela CTH."
                    Break
                EndIf

                If CTH->CTH_BLOQ == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCLVLR) + " do campo AKD_CLVLR bloqueado na tabela CTH."
                    Break
                EndIf

                cClasse := padr(oAKD:AAKD[nFor]:AKD_CLASSE,TamSX3("AKD_CLASSE")[1])
                If !AK6->(msSeek(xFilial("AK6")+cClasse)) .and. !Empty(cClasse)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cClasse) + " do campo AKD_CLASSE vazio ou nao encontrado na tabela AK6."
                    Break
                EndIf
                
                //****************************************************************
                /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
                
                /* 
                Neste bloco de c�digo, estamos realizando uma s�rie de verifica��es nos dados do objeto JSON recebido para garantir que estejam corretos e consistentes antes de prosseguir com o processamento.
                - '_cFilial := oAKD:AAKD[nFor]:AKD_FILIAL': Atribui o valor do campo AKD_FILIAL do objeto JSON a uma vari�vel local.
                - 'If Empty(_cFilial)': Verifica se o campo AKD_FILIAL est� vazio.
                    - Se estiver vazio, define uma mensagem de erro no objeto aAKDRet e interrompe o loop.
                - 'cChavePesq := "01"+_cFilial': Monta uma chave de pesquisa para consultar a tabela SM0.
                - 'If SM0->(msSeek(cChavePesq))': Verifica se a filial existe na tabela SM0.
                    - Se n�o existir, define uma mensagem de erro no objeto aAKDRet e interrompe o loop.
                - 'cData := oAKD:AAKD[nFor]:AKD_DATA': Atribui o valor do campo AKD_DATA do objeto JSON a uma vari�vel local.
                - 'If Empty(cData)': Verifica se o campo AKD_DATA est� vazio.
                    - Se estiver vazio, define uma mensagem de erro no objeto aAKDRet e interrompe o loop.
                - 'cHist := oAKD:AAKD[nFor]:AKD_HIST': Atribui o valor do campo AKD_HIST do objeto JSON a uma vari�vel local.
                - 'If Empty(cHist)': Verifica se o campo AKD_HIST est� vazio.
                    - Se estiver vazio, define uma mensagem de erro no objeto aAKDRet e interrompe o loop.
                - E assim por diante, para cada campo que precisa ser validado.
                */
                //****************************************************************


                */
                //****************************************************************
                
                If Empty(_clote)
                    _clote := GETSXENUM("AKD","AKD_LOTE","AKD" + _cFilial)
                    ConfirmSx8()
                    While .T.
                        If AKD->(msSeek(_cFilial + _clote))
                            _clote := GETSXENUM("AKD","AKD_LOTE","AKD" + _cFilial)
                            ConfirmSx8()
                        Else
                            Exit
                        EndIf
                    EndDo
                EndIf

                //****************************************************************
                /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
                
                Neste trecho de c�digo, estamos verificando se a vari�vel _clote est� vazia.
                - 'If Empty(_clote)': Verifica se a vari�vel _clote est� vazia.
                    - Se estiver vazia, significa que ainda n�o foi atribu�do um valor a ela.
                    - Dentro deste bloco, realizamos as seguintes opera��es:
                        1. '_clote := GETSXENUM("AKD","AKD_LOTE","AKD" + _cFilial)': Obt�m um n�mero de lote da tabela AKD usando a fun��o GETSXENUM, concatenando o c�digo da filial ao prefixo "AKD".
                        2. 'ConfirmSx8()': Confirma a execu��o da transa��o.
                        3. 'While .T.': Inicia um loop infinito.
                        4. 'If AKD->(msSeek(_cFilial + _clote))': Verifica se o n�mero de lote j� existe na tabela AKD.
                            - Se existir, repete o processo para obter um novo n�mero de lote.
                            - Caso contr�rio, sai do loop.
                        5. 'EndDo': Fim do loop.
                - Este bloco de c�digo garante que tenhamos um n�mero de lote v�lido e �nico para cada transa��o na tabela AKD.
                
                */
                //****************************************************************

                _cID++
                Begin Transaction
                If RecLock("AKD",.T.)
                    AKD->AKD_FILIAL := _cFilial
                    AKD->AKD_FILORI := _cFilial
                    AKD->AKD_LOTE   := _clote
                    AKD->AKD_ID     := strZero(_cID,4)
                    AKD->AKD_DATA   := CTOD(cData)
                    AKD->AKD_CO     := cConta
                    AKD->AKD_TPSALD := cTpSld
                    AKD->AKD_HIST   := cHist
                    AKD->AKD_COSUP  := Substr(cConta,1,5)
                    AKD->AKD_VALOR1 := nValor
                    AKD->AKD_CC     := cCC
                    AKD->AKD_ITCTB  := cITCTB
                    AKD->AKD_CLVLR  := cCLVLR
                    AKD->AKD_STATUS := "1"
                    AKD->AKD_CLASSE := cClasse
                    AKD->AKD_TIPO   := cTipo
                    AKD->(MsUnLock())

                    aAKDRet[_nX][ 'mensagem' ] := "Lancamento Importado com sucesso."
                    aAKDRet[_nX][ 'lote' ]     := alltrim(_clote)
                Else
                    aAKDRet[_nX][ 'mensagem' ] := "Nao foi possivel gravar o lancamento."
                    aAKDRet[_nX][ 'lote' ]     := alltrim(_clote)
                EndIf

                //****************************************************************
                /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
                
                Nesta se��o do c�digo, estamos inserindo um novo registro na tabela AKD com os dados fornecidos.
                - '_cID++': Incrementa o valor da vari�vel _cID, que representa o identificador do registro.
                - 'Begin Transaction': Inicia uma nova transa��o.
                - 'If RecLock("AKD",.T.)': Realiza um bloqueio de registro na tabela AKD.
                    - Se o bloqueio for bem-sucedido, o c�digo dentro deste bloco � executado:
                        - Os campos da tabela AKD s�o preenchidos com os valores correspondentes.
                        - 'AKD->(MsUnLock())': Desbloqueia o registro.
                        - A mensagem de sucesso e o n�mero do lote s�o atribu�dos ao array aAKDRet.
                    - Caso contr�rio, se o bloqueio n�o for bem-sucedido, o c�digo dentro do bloco 'Else' � executado:
                        - A mensagem de falha e o n�mero do lote s�o atribu�dos ao array aAKDRet.
                - Este bloco de c�digo garante a inser��o segura e controlada de um novo lan�amento na tabela AKD, evitando conflitos e inconsist�ncias.
                */

                */
                //****************************************************************


                End Transaction
            END SEQUENCE
        Next nFor
	Else
		cMsgAux := "JSON nao foi especificado corretamente no corpo da requisicao, verifique."
		SetRestFault(12, cMsgAux)
        //****************************************************************
        /* Com o seu conhecimento, descreva a utiliza��o/finalidade da fun��o acima:  

            Esta fun��o � usada para configurar um erro na resposta do servi�o REST, caso o JSON n�o tenha sido especificado corretamente no corpo da requisi��o. O c�digo de erro 12 � comumente usado para indicar erros relacionados � entrada de dados.

        */
        //****************************************************************

		fStrDatHor(cMsgAux)
		lRet := .F.
	EndIf

	fStrDatHor("Preparando retorno")
    oAKDRet := JsonObject():New()
    oAKDRet[ '_classname' ] := "myAPI"
    oAKDRet[ 'AAKD' ]       := aAKDRet

    ::SetResponse(oAKDRet)

    //****************************************************************
    /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
    
        Este bloco prepara a resposta do servi�o REST com os dados processados. Um objeto JSON � criado para conter os resultados do processamento e � enviado como resposta � requisi��o.

    */
    //****************************************************************

	RestArea(aAreaAKD)
	RestArea(aArea)
	fStrDatHor("Metodo POST finalizado")
Return(lRet)

Static Function fStrDatHor(cMsg)
	ConOut(DToC(Date())+"-"+Time()+" (myAPI) -> " + cValToChar(cMsg))

    //****************************************************************
    /* Com o seu conhecimento, descreva a utiliza��o/finalidade da fun��o acima:  

            Esta fun��o � usada para registrar mensagens de log com a data, hora e uma mensagem espec�fica. � �til para fins de depura��o e acompanhamento do fluxo de execu��o do c�digo.

    */
    //****************************************************************
Return
