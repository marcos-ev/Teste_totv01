#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function MyMata410
    Fonte utilizado para testes e treinamentos. 
    Este documento � de propriedade da TOTVS. Todos os direitos reservados.

    IMPORTANTE: Para avalia��o, preencha todos os blocos de coment�rios de 
    acordo com a descri��o inserida.

    @type  Function
    @author gabriel.antonio@totvs.com.br
    /*/

User Function MyMata410(cOper)

	Local cDoc       := ""                                                                 // N�mero do Pedido de Vendas
	Local cA1Cod     := "000001"                                                           // C�digo do Cliente
	Local cA1Loja    := "01"                                                               // Loja do Cliente
	Local cB1Cod     := "000000000000000000000000000061"                                   // C�digo do Produto
	Local cF4TES     := "501"                                                              // C�digo do TES
	Local cE4Codigo  := "001"                                                              // C�digo da Condi��o de Pagamento
	Local aAGGCC     := {"FAT000001", "FAT000002", "FAT000003", "FAT000004", "FAT000005"}  // C�digos dos Centros de Custo
	Local cMsgLog    := ""
	Local cLogErro   := ""
	Local cFilAGG    := ""
	Local cFilSA1    := ""
	Local cFilSB1    := ""
	Local cFilSE4    := ""
	Local cFilSF4    := ""
	Local nTmAGGItPd := TamSx3("AGG_ITEMPD")[1]
	Local nTmAGGItem := TamSx3("AGG_ITEM")[1]
	Local nOpcX      := 0
	Local nX         := 0
	Local nY         := 0
	Local nCount     := 0
	Local aCabec     := {}
	Local aItens     := {}
	Local aLinha     := {}
	Local aRatAGG    := {}
	Local aItemRat   := {}
	Local aAuxRat    := {}
	Local aErroAuto  := {}
	Local lOk        := .T.

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	Default cOper := 1

	//****************************************************************
    /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
    
    Esta fun��o, denominada MyMata410, � um m�dulo de processamento de pedidos de venda no sistema Protheus. Ela aceita um argumento "cOper" que controla o tipo de opera��o a ser realizada.

    No in�cio, s�o definidas v�rias vari�veis locais que armazenam informa��es importantes relacionadas ao pedido de venda. Por exemplo:
    "cA1Cod" representa o c�digo do cliente.
    "cB1Cod" � o c�digo do produto.
    "cF4TES" � o c�digo do TES (Tipo de Documento).
    "cE4Codigo" � o c�digo da condi��o de pagamento.
    "aAGGCC" � um array contendo os c�digos dos centros de custo.

    O c�digo tamb�m inclui vari�veis para manipula��o de mensagens de log e poss�veis erros durante a execu��o da fun��o.

    Por padr�o, se nenhum argumento for fornecido para "cOper", ele ser� configurado como 1.
    */
	//****************************************************************

	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
	//****************************************************************

    /* Com o seu conhecimento, descreva a utiliza��o/finalidade da fun��o acima:  


    Antes de iniciar as opera��es de manipula��o de dados, � necess�rio preparar o ambiente e configurar as tabelas relevantes.
    
    
    A fun��o PREPARE ENVIRONMENT acima � utilizada para preparar o ambiente de trabalho para o m�dulo Faturamento (FAT) da empresa "99" e filial "01" no sistema Protheus. Ela define:

    Empresa: "99"
    Filial: "01"
    M�dulo: "FAT"
    Tabelas: SC5, SC6, SA1, SA2, SB1, SB2 e SF4
    

    */
	//****************************************************************

	SA1->(dbSetOrder(1))
	SB1->(dbSetOrder(1))
	SE4->(dbSetOrder(1))
	SF4->(dbSetOrder(1))

	cFilAGG := xFilial("AGG")
	cFilSA1 := xFilial("SA1")
	cFilSB1 := xFilial("SB1")
	cFilSE4 := xFilial("SE4")
	cFilSF4 := xFilial("SF4")

	//****************************************************************
    /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
    
    . Defini��o da Ordem das Tabelas:

        Define a ordem em que as tabelas SA1, SB1, SE4 e SF4 ser�o exibidas em consultas ou opera��es que envolvam m�ltiplas tabelas.
        A fun��o dbSetOrder(1) define a ordem de cada tabela como 1, o que significa que elas ser�o as primeiras a serem exibidas.
        Depois Recupera a filial associada a cada tabela, ex:

        Fun��es como xFilial("xxx") s�o usadas para obter a filial de uma tabela espec�fica.

    */
	//****************************************************************

	If SB1->(! MsSeek(cFilSB1 + cB1Cod))
		cMsgLog += "Cadastrar o Produto: " + cB1Cod + CRLF
		lOk     := .F.
	EndIf

	If SF4->(! MsSeek(cFilSF4 + cF4TES))
		cMsgLog += "Cadastrar o TES: " + cF4TES + CRLF
		lOk     := .F.
	EndIf

	If SE4->(! MsSeek(cFilSE4 + cE4Codigo))
		cMsgLog += "Cadastrar a Condi��o de Pagamento: " + cE4Codigo + CRLF
		lOk     := .F.
	EndIf

	If SA1->(! MsSeek(cFilSA1 + cA1Cod + cA1Loja))
		cMsgLog += "Cadastrar o Cliente: " + cA1Cod + " Loja: " + cA1Loja + CRLF
		lOk     := .F.
	EndIf

	//****************************************************************
    /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
    
    Verifica se os dados necess�rios para uma opera��o existem no Protheus.

     Verifica se cada registro existe na tabela:
     Produto (SB1), TES (SF4), Condi��o de Pagamento (SE4), Cliente (SA1).
     Se n�o encontrar, registra erro e define lOk como Falso.

     Garante que os dados existam antes de continuar.
        Se faltar algo, avisa o usu�rio e pode parar a opera��o.
    */
	//****************************************************************

	If lOk

		cDoc := GetSxeNum("SC5", "C5_NUM")
		//****************************************************************
        /* Com o seu conhecimento, descreva a utiliza��o/finalidade da fun��o acima:  

        A fun��o retorna o pr�ximo n�mero dispon�vel para o campo especificado. 
        No contexto do c�digo, o pr�ximo n�mero da tabela "SC5" para o campo "C5_NUM" ser� armazenado na vari�vel cDoc.
        */
		//****************************************************************

		If cOper == 1

			aCabec   := {}
			aItens   := {}
			aLinha   := {}
			aRatAGG  := {}
			aItemRat := {}
			aAuxRat  := {}
			aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
			aadd(aCabec, {"C5_TIPO",    "N",       Nil})
			aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
			aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
			aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
			aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})

			If cPaisLoc == "PTG"
				aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
			Endif

			For nX := 1 To 02
				aLinha := {}
				aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
				aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
				aadd(aLinha,{"C6_QTDVEN",  1,             Nil})
				aadd(aLinha,{"C6_PRCVEN",  1000,          Nil})
				aadd(aLinha,{"C6_PRUNIT",  1000,          Nil})
				aadd(aLinha,{"C6_VALOR",   1000,          Nil})
				aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
				aadd(aLinha,{"C6_RATEIO",  "1",           Nil})
				aadd(aItens, aLinha)

				aAuxRat     := {}
				For nY := 1 to 04
					aRatAGG := {}
					aAdd(aRatAGG, {"AGG_FILIAL",  cFilAGG,                Nil})
					aAdd(aRatAGG, {"AGG_PEDIDO",  cDoc,                   Nil})
					aAdd(aRatAGG, {"AGG_FORNECE", cA1Cod,                 Nil})
					aAdd(aRatAGG, {"AGG_LOJA",    cA1Loja,                Nil})
					aAdd(aRatAGG, {"AGG_ITEMPD",  StrZero(nX,nTmAGGItPd), Nil})
					aAdd(aRatAGG, {"AGG_ITEM",    Strzero(nY,nTmAGGItem), Nil})
					aAdd(aRatAGG, {"AGG_PERC",    25,                     Nil})
					aAdd(aRatAGG, {"AGG_CC",      aAGGCC[nY],             Nil})
					aAdd(aRatAGG, {"AGG_CONTA",   "",                     Nil})
					aAdd(aRatAGG, {"AGG_ITEMCT",  "",                     Nil})
					aAdd(aRatAGG, {"AGG_CLVL",    "",                     Nil})
					aAdd(aAuxRat, aRatAGG)
				Next nY
				aAdd(aItemRat, {StrZero(nX,2), aAuxRat})

			Next nX

			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            
            
                Esse trecho de c�digo cria e preenche estruturas de dados para representar informa��es de transa��es de vendas,
                incluindo cabe�alhos, itens e informa��es de rateio.

                Inicialmente, verifica-se se cOper � igual a 1 para prosseguir com o processamento. Em seguida, s�o inicializados arrays vazios para armazenar os cabe�alhos (aCabec), itens (aItens), linhas (aLinha), informa��es de rateio agregadas (aRatAGG), itens de rateio (aItemRat) e auxiliares de rateio (aAuxRat).

                Os campos do cabe�alho da transa��o s�o adicionados ao array aCabec, incluindo n�mero do documento, tipo, cliente, lojas relacionadas e condi��o de pagamento. Se cPaisLoc for "PTG", � adicionado um campo adicional chamado "C5_DECLEXP" com o valor "TESTE".

                Dentro de um loop For, s�o criados e adicionados itens � transa��o. Para cada item, s�o preenchidos os campos como n�mero do item, c�digo do produto, quantidade vendida, pre�o de venda, pre�o unit�rio, valor e tipo de TES. Os itens s�o ent�o adicionados ao array aItens.

                Dentro do mesmo loop de itens, h� um loop interno para preencher informa��es de rateio para cada item. Para cada item, s�o adicionadas informa��es como filial, pedido, fornecedor, loja, percentual de rateio, centro de custo, conta e outros detalhes de rateio. Essas informa��es s�o armazenadas em arrays intermedi�rios e, em seguida, adicionadas ao array aItemRat, representando todas as informa��es de rateio para todos os itens da transa��o.

            Resumindo...este bloco de c�digo organiza e preenche estruturas de dados para representar transa��es de vendas, juntamente com detalhes de rateio associados a cada item.


            */
			//****************************************************************

			nOpcX := 3
			MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )}, aCabec, aItens, nOpcX, .F., aItemRat)
			If !lMsErroAuto
				ConOut("Incluido com sucesso! " + cDoc)
			Else
				ConOut("Erro na inclusao!")
				aErroAuto := GetAutoGRLog()
				For nCount := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
					ConOut(cLogErro)
				Next nCount
			EndIf
			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:

            Primeiramente nOpcX � definido como 3.  Em seguida, � feita uma chamada para a fun��o MSExecAuto com alguns par�metros.
             Esta fun��o parece estar relacionada a algum tipo de opera��o automatizada, possivelmente envolvendo a execu��o de um procedimento espec�fico como a opera��o de incluir um novo Pedido de Vendas. Ap�s a execu��o desta fun��o, � verificado se ocorreu algum erro. Se n�o houver erro, uma mensagem de sucesso � exibida juntamente com o n�mero do documento (cDoc). Caso contr�rio, � exibida uma mensagem de erro e detalhes do erro s�o obtidos usando a fun��o GetAutoGRLog(). Em seguida, os detalhes do erro s�o percorridos e concatenados em uma string, que � ent�o exibida na sa�da.

            Resumindo, este bloco de c�digo parece lidar com uma opera��o automatizada de inclus�o, verifica��o se houve sucesso ou falha e exibindo mensagens correspondentes.

            */
			//****************************************************************



		ElseIf cOper == 2

			aCabec         := {}
			aItens         := {}
			aLinha         := {}
			aRatAGG        := {}
			aItemRat       := {}
			aAuxRat        := {}
			lMsErroAuto    := .F.
			lAutoErrNoFile := .F.

			aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
			aadd(aCabec, {"C5_TIPO",    "N",       Nil})
			aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
			aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
			aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
			aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})

			If cPaisLoc == "PTG"
				aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
			Endif

			For nX := 1 To 02

				aLinha := {}
				aadd(aLinha,{"LINPOS",     "C6_ITEM",     StrZero(nX,2)})
				aadd(aLinha,{"AUTDELETA",  "N",           Nil})
				aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
				aadd(aLinha,{"C6_QTDVEN",  2,             Nil})
				aadd(aLinha,{"C6_PRCVEN",  2000,          Nil})
				aadd(aLinha,{"C6_PRUNIT",  2000,          Nil})
				aadd(aLinha,{"C6_VALOR",   4000,          Nil})
				aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
				aadd(aLinha,{"C6_RATEIO",  "1",           Nil})
				aadd(aItens, aLinha)

				aAuxRat     := {}
				For nY := 1 to 05
					aRatAGG := {}
					aAdd(aRatAGG, {"AGG_FILIAL",  cFilAGG,                Nil})
					aAdd(aRatAGG, {"AGG_PEDIDO",  cDoc,                   Nil})
					aAdd(aRatAGG, {"AGG_FORNECE", cA1Cod,                 Nil})
					aAdd(aRatAGG, {"AGG_LOJA",    cA1Loja,                Nil})
					aAdd(aRatAGG, {"AGG_ITEMPD",  StrZero(nX,nTmAGGItPd), Nil})
					aAdd(aRatAGG, {"AGG_ITEM",    Strzero(nY,nTmAGGItem), Nil})
					aAdd(aRatAGG, {"AGG_PERC",    20,                     Nil})
					aAdd(aRatAGG, {"AGG_CC",      aAGGCC[nY],             Nil})
					aAdd(aRatAGG, {"AGG_CONTA",   "",                     Nil})
					aAdd(aRatAGG, {"AGG_ITEMCT",  "",                     Nil})
					aAdd(aRatAGG, {"AGG_CLVL",    "",                     Nil})
					aAdd(aAuxRat, aRatAGG)
				Next nY
				aAdd(aItemRat, {StrZero(nX,2), aAuxRat})
			Next nX

			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            
        Neste bloco de c�digo, a l�gica � direcionada com base no valor da vari�vel cOper. Se cOper for igual a 2, o c�digo executa uma opera��o diferente daquela realizada quando cOper � igual a 1. Primeiramente, s�o inicializados v�rios arrays vazios para armazenar informa��es relacionadas ao cabe�alho, itens e rateio da transa��o. Al�m disso, duas vari�veis l�gicas, lMsErroAuto e lAutoErrNoFile, s�o definidas como falso. 
        
        Em seguida, s�o preenchidas as informa��es do cabe�alho da transa��o, como n�mero do documento, tipo, cliente, lojas relacionadas e condi��o de pagamento. Se cPaisLoc for igual a "PTG", um campo adicional chamado "C5_DECLEXP" com o valor "TESTE" � adicionado ao cabe�alho. Posteriormente, � iniciado um loop para criar e adicionar itens � transa��o de vendas. Para cada item, s�o preenchidos campos como n�mero do item, c�digo do produto, quantidade vendida, pre�o de venda, pre�o unit�rio, valor e tipo de TES. Os itens s�o ent�o adicionados ao array de itens (aItens). 
        
        Dentro do mesmo loop de itens, h� outro loop interno para preencher informa��es de rateio para cada item. Para cada item, s�o adicionadas informa��es como filial, pedido, fornecedor, loja, percentual de rateio, centro de custo, conta e outros detalhes de rateio. Essas informa��es s�o armazenadas em arrays intermedi�rios e, em seguida, adicionadas ao array de itens de rateio (aItemRat).
        
        O bloco de c�digo prepara uma transa��o de vendas com base em uma opera��o espec�fica (identificada pelo valor de cOper) 
            */
			//****************************************************************

			nOpcX := 4
			MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )}, aCabec, aItens, nOpcX, .F., aItemRat)
			If !lMsErroAuto
				ConOut("Alterado com sucesso! " + cDoc)
			Else
				ConOut("Erro na altera��o!")
				aErroAuto := GetAutoGRLog()
				For nCount := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
					ConOut(cLogErro)
				Next nCount
			EndIf

			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            

            Parece ser parte de um sistema de processamento de pedidos de venda, onde a fun��o MyMata410 � utilizada para realizar opera��es automatizadas de acordo com o tipo de opera��o especificado pelo argumento cOper.

            A vari�vel nOpcX � definida como 4, possivelmente indicando o tipo espec�fico de opera��o a ser executada. Em seguida, a fun��o MSExecAuto � chamada, possivelmente para executar uma opera��o automatizada relacionada ao processamento de pedidos de venda. Esta fun��o recebe v�rios par�metros, incluindo uma fun��o an�nima ou callback, juntamente com arrays contendo informa��es sobre o cabe�alho e os itens do pedido de venda.

            Depois que a opera��o � executada, o c�digo verifica se houve algum erro (!lMsErroAuto). Se n�o houver erro, uma mensagem de sucesso � exibida, indicando que a altera��o foi realizada com sucesso, juntamente com o n�mero do documento do pedido de venda. Se ocorrer um erro, uma mensagem de erro � exibida e os detalhes do erro s�o recuperados da fun��o GetAutoGRLog()

            */
			//****************************************************************


		ElseIf cOper == 3


			ConOut(PadC("Teste de exclus�o",80))

			aCabec         := {}
			aItens         := {}
			aLinha         := {}
			aRatAGG        := {}
			aItemRat       := {}
			aAuxRat        := {}
			lMsErroAuto    := .F.
			lAutoErrNoFile := .F.

			aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
			aadd(aCabec, {"C5_TIPO",    "N",       Nil})
			aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
			aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
			aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
			aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})

			If cPaisLoc == "PTG"
				aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
			Endif

			For nX := 1 To 02
				//--- Informando os dados do item do Pedido de Venda
				aLinha := {}
				aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
				aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
				aadd(aLinha,{"C6_QTDVEN",  2,             Nil})
				aadd(aLinha,{"C6_PRCVEN",  2000,          Nil})
				aadd(aLinha,{"C6_PRUNIT",  2000,          Nil})
				aadd(aLinha,{"C6_VALOR",   4000,          Nil})
				aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
				aadd(aLinha,{"C6_RATEIO",  "1",           Nil})
				aadd(aItens, aLinha)
			Next nX

			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            
            Parece estar preparando uma transa��o de vendas para realizar uma opera��o de exclus�o, onde s�o fornecidos os dados necess�rios para a execu��o dessa opera��o. Se cOper for igual a 3, a l�gica executar� uma opera��o de exclus�o. s�o inicializados arrays vazios para armazenar informa��es relacionadas ao cabe�alho, itens e rateio da transa��o, juntamente com outras vari�veis de controle.
            
            As informa��es do cabe�alho da transa��o s�o preenchidas, incluindo n�mero do documento, tipo, cliente, lojas relacionadas e condi��o de pagamento. Se cPaisLoc for igual a "PTG", um campo adicional chamado "C5_DECLEXP" com o valor "TESTE" � adicionado ao cabe�alho.
            
            Posteriormente, � iniciado um loop para criar e adicionar itens � transa��o de vendas. Para cada item, s�o preenchidos campos como n�mero do item, c�digo do produto, quantidade vendida, pre�o de venda, pre�o unit�rio, valor e tipo de TES. Os itens s�o ent�o adicionados ao array de itens (aItens).


            */
			//****************************************************************

			MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)
			If !lMsErroAuto
				ConOut("Exclu�do com sucesso! " + cDoc)
			Else
				ConOut("Erro na exclus�o!")
			EndIf

			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            
                A opera��o parece estar relacionada � exclus�o de um pedido de vendas, pois a fun��o MATA410 � utilizada para executar a exclus�o.

                os arrays aCabec e aItens s�o fornecidos como par�metros, contendo informa��es sobre o cabe�alho e os itens do pedido de vendas. O valor 5 tamb�m � passado como argumento adicional para MSExecAuto.
                
                Em seguida, o c�digo verifica se houve algum erro durante a opera��o automatizada, usando a vari�vel lMsErroAuto. Se n�o houver erro, uma mensagem de sucesso � exibida, indicando que a exclus�o foi realizada com sucesso, juntamente com o n�mero do documento do pedido de vendas. Se ocorrer um erro, uma mensagem de erro � exibida.
            */
			//****************************************************************

		EndIf
	Else

		ConOut(cMsgLog)

	EndIf

	ConOut("Fim: " + Time())

	RESET ENVIRONMENT
Return(.T.)
