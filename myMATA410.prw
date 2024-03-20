#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function MyMata410
    Fonte utilizado para testes e treinamentos. 
    Este documento é de propriedade da TOTVS. Todos os direitos reservados.

    IMPORTANTE: Para avaliação, preencha todos os blocos de comentários de 
    acordo com a descrição inserida.

    @type  Function
    @author gabriel.antonio@totvs.com.br
    /*/

User Function MyMata410(cOper)

	Local cDoc       := ""                                                                 // Número do Pedido de Vendas
	Local cA1Cod     := "000001"                                                           // Código do Cliente
	Local cA1Loja    := "01"                                                               // Loja do Cliente
	Local cB1Cod     := "000000000000000000000000000061"                                   // Código do Produto
	Local cF4TES     := "501"                                                              // Código do TES
	Local cE4Codigo  := "001"                                                              // Código da Condição de Pagamento
	Local aAGGCC     := {"FAT000001", "FAT000002", "FAT000003", "FAT000004", "FAT000005"}  // Códigos dos Centros de Custo
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
    /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
    
    Esta função, denominada MyMata410, é um módulo de processamento de pedidos de venda no sistema Protheus. Ela aceita um argumento "cOper" que controla o tipo de operação a ser realizada.

    No início, são definidas várias variáveis locais que armazenam informações importantes relacionadas ao pedido de venda. Por exemplo:
    "cA1Cod" representa o código do cliente.
    "cB1Cod" é o código do produto.
    "cF4TES" é o código do TES (Tipo de Documento).
    "cE4Codigo" é o código da condição de pagamento.
    "aAGGCC" é um array contendo os códigos dos centros de custo.

    O código também inclui variáveis para manipulação de mensagens de log e possíveis erros durante a execução da função.

    Por padrão, se nenhum argumento for fornecido para "cOper", ele será configurado como 1.
    */
	//****************************************************************

	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
	//****************************************************************

    /* Com o seu conhecimento, descreva a utilização/finalidade da função acima:  


    Antes de iniciar as operações de manipulação de dados, é necessário preparar o ambiente e configurar as tabelas relevantes.
    
    
    A função PREPARE ENVIRONMENT acima é utilizada para preparar o ambiente de trabalho para o módulo Faturamento (FAT) da empresa "99" e filial "01" no sistema Protheus. Ela define:

    Empresa: "99"
    Filial: "01"
    Módulo: "FAT"
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
    /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
    
    . Definição da Ordem das Tabelas:

        Define a ordem em que as tabelas SA1, SB1, SE4 e SF4 serão exibidas em consultas ou operações que envolvam múltiplas tabelas.
        A função dbSetOrder(1) define a ordem de cada tabela como 1, o que significa que elas serão as primeiras a serem exibidas.
        Depois Recupera a filial associada a cada tabela, ex:

        Funções como xFilial("xxx") são usadas para obter a filial de uma tabela específica.

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
		cMsgLog += "Cadastrar a Condição de Pagamento: " + cE4Codigo + CRLF
		lOk     := .F.
	EndIf

	If SA1->(! MsSeek(cFilSA1 + cA1Cod + cA1Loja))
		cMsgLog += "Cadastrar o Cliente: " + cA1Cod + " Loja: " + cA1Loja + CRLF
		lOk     := .F.
	EndIf

	//****************************************************************
    /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
    
    Verifica se os dados necessários para uma operação existem no Protheus.

     Verifica se cada registro existe na tabela:
     Produto (SB1), TES (SF4), Condição de Pagamento (SE4), Cliente (SA1).
     Se não encontrar, registra erro e define lOk como Falso.

     Garante que os dados existam antes de continuar.
        Se faltar algo, avisa o usuário e pode parar a operação.
    */
	//****************************************************************

	If lOk

		cDoc := GetSxeNum("SC5", "C5_NUM")
		//****************************************************************
        /* Com o seu conhecimento, descreva a utilização/finalidade da função acima:  

        A função retorna o próximo número disponível para o campo especificado. 
        No contexto do código, o próximo número da tabela "SC5" para o campo "C5_NUM" será armazenado na variável cDoc.
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
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            
            
                Esse trecho de código cria e preenche estruturas de dados para representar informações de transações de vendas,
                incluindo cabeçalhos, itens e informações de rateio.

                Inicialmente, verifica-se se cOper é igual a 1 para prosseguir com o processamento. Em seguida, são inicializados arrays vazios para armazenar os cabeçalhos (aCabec), itens (aItens), linhas (aLinha), informações de rateio agregadas (aRatAGG), itens de rateio (aItemRat) e auxiliares de rateio (aAuxRat).

                Os campos do cabeçalho da transação são adicionados ao array aCabec, incluindo número do documento, tipo, cliente, lojas relacionadas e condição de pagamento. Se cPaisLoc for "PTG", é adicionado um campo adicional chamado "C5_DECLEXP" com o valor "TESTE".

                Dentro de um loop For, são criados e adicionados itens à transação. Para cada item, são preenchidos os campos como número do item, código do produto, quantidade vendida, preço de venda, preço unitário, valor e tipo de TES. Os itens são então adicionados ao array aItens.

                Dentro do mesmo loop de itens, há um loop interno para preencher informações de rateio para cada item. Para cada item, são adicionadas informações como filial, pedido, fornecedor, loja, percentual de rateio, centro de custo, conta e outros detalhes de rateio. Essas informações são armazenadas em arrays intermediários e, em seguida, adicionadas ao array aItemRat, representando todas as informações de rateio para todos os itens da transação.

            Resumindo...este bloco de código organiza e preenche estruturas de dados para representar transações de vendas, juntamente com detalhes de rateio associados a cada item.


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
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:

            Primeiramente nOpcX é definido como 3.  Em seguida, é feita uma chamada para a função MSExecAuto com alguns parâmetros.
             Esta função parece estar relacionada a algum tipo de operação automatizada, possivelmente envolvendo a execução de um procedimento específico como a operação de incluir um novo Pedido de Vendas. Após a execução desta função, é verificado se ocorreu algum erro. Se não houver erro, uma mensagem de sucesso é exibida juntamente com o número do documento (cDoc). Caso contrário, é exibida uma mensagem de erro e detalhes do erro são obtidos usando a função GetAutoGRLog(). Em seguida, os detalhes do erro são percorridos e concatenados em uma string, que é então exibida na saída.

            Resumindo, este bloco de código parece lidar com uma operação automatizada de inclusão, verificação se houve sucesso ou falha e exibindo mensagens correspondentes.

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
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            
        Neste bloco de código, a lógica é direcionada com base no valor da variável cOper. Se cOper for igual a 2, o código executa uma operação diferente daquela realizada quando cOper é igual a 1. Primeiramente, são inicializados vários arrays vazios para armazenar informações relacionadas ao cabeçalho, itens e rateio da transação. Além disso, duas variáveis lógicas, lMsErroAuto e lAutoErrNoFile, são definidas como falso. 
        
        Em seguida, são preenchidas as informações do cabeçalho da transação, como número do documento, tipo, cliente, lojas relacionadas e condição de pagamento. Se cPaisLoc for igual a "PTG", um campo adicional chamado "C5_DECLEXP" com o valor "TESTE" é adicionado ao cabeçalho. Posteriormente, é iniciado um loop para criar e adicionar itens à transação de vendas. Para cada item, são preenchidos campos como número do item, código do produto, quantidade vendida, preço de venda, preço unitário, valor e tipo de TES. Os itens são então adicionados ao array de itens (aItens). 
        
        Dentro do mesmo loop de itens, há outro loop interno para preencher informações de rateio para cada item. Para cada item, são adicionadas informações como filial, pedido, fornecedor, loja, percentual de rateio, centro de custo, conta e outros detalhes de rateio. Essas informações são armazenadas em arrays intermediários e, em seguida, adicionadas ao array de itens de rateio (aItemRat).
        
        O bloco de código prepara uma transação de vendas com base em uma operação específica (identificada pelo valor de cOper) 
            */
			//****************************************************************

			nOpcX := 4
			MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )}, aCabec, aItens, nOpcX, .F., aItemRat)
			If !lMsErroAuto
				ConOut("Alterado com sucesso! " + cDoc)
			Else
				ConOut("Erro na alteração!")
				aErroAuto := GetAutoGRLog()
				For nCount := 1 To Len(aErroAuto)
					cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
					ConOut(cLogErro)
				Next nCount
			EndIf

			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            

            Parece ser parte de um sistema de processamento de pedidos de venda, onde a função MyMata410 é utilizada para realizar operações automatizadas de acordo com o tipo de operação especificado pelo argumento cOper.

            A variável nOpcX é definida como 4, possivelmente indicando o tipo específico de operação a ser executada. Em seguida, a função MSExecAuto é chamada, possivelmente para executar uma operação automatizada relacionada ao processamento de pedidos de venda. Esta função recebe vários parâmetros, incluindo uma função anônima ou callback, juntamente com arrays contendo informações sobre o cabeçalho e os itens do pedido de venda.

            Depois que a operação é executada, o código verifica se houve algum erro (!lMsErroAuto). Se não houver erro, uma mensagem de sucesso é exibida, indicando que a alteração foi realizada com sucesso, juntamente com o número do documento do pedido de venda. Se ocorrer um erro, uma mensagem de erro é exibida e os detalhes do erro são recuperados da função GetAutoGRLog()

            */
			//****************************************************************


		ElseIf cOper == 3


			ConOut(PadC("Teste de exclusão",80))

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
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            
            Parece estar preparando uma transação de vendas para realizar uma operação de exclusão, onde são fornecidos os dados necessários para a execução dessa operação. Se cOper for igual a 3, a lógica executará uma operação de exclusão. são inicializados arrays vazios para armazenar informações relacionadas ao cabeçalho, itens e rateio da transação, juntamente com outras variáveis de controle.
            
            As informações do cabeçalho da transação são preenchidas, incluindo número do documento, tipo, cliente, lojas relacionadas e condição de pagamento. Se cPaisLoc for igual a "PTG", um campo adicional chamado "C5_DECLEXP" com o valor "TESTE" é adicionado ao cabeçalho.
            
            Posteriormente, é iniciado um loop para criar e adicionar itens à transação de vendas. Para cada item, são preenchidos campos como número do item, código do produto, quantidade vendida, preço de venda, preço unitário, valor e tipo de TES. Os itens são então adicionados ao array de itens (aItens).


            */
			//****************************************************************

			MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)
			If !lMsErroAuto
				ConOut("Excluído com sucesso! " + cDoc)
			Else
				ConOut("Erro na exclusão!")
			EndIf

			//****************************************************************
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            
                A operação parece estar relacionada à exclusão de um pedido de vendas, pois a função MATA410 é utilizada para executar a exclusão.

                os arrays aCabec e aItens são fornecidos como parâmetros, contendo informações sobre o cabeçalho e os itens do pedido de vendas. O valor 5 também é passado como argumento adicional para MSExecAuto.
                
                Em seguida, o código verifica se houve algum erro durante a operação automatizada, usando a variável lMsErroAuto. Se não houver erro, uma mensagem de sucesso é exibida, indicando que a exclusão foi realizada com sucesso, juntamente com o número do documento do pedido de vendas. Se ocorrer um erro, uma mensagem de erro é exibida.
            */
			//****************************************************************

		EndIf
	Else

		ConOut(cMsgLog)

	EndIf

	ConOut("Fim: " + Time())

	RESET ENVIRONMENT
Return(.T.)
