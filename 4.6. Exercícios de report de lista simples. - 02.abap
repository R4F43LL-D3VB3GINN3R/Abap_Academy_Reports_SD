------------------------------------------------------------------------------------------------------------------------------
2.

*&---------------------------------------------------------------------*
*& Report ZREPORT_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_2.

*2 - Elaborar um programa ABAP onde deverão ser selecionados na tabela EKKO

TABLES: ekko, "Cabeçalho do documento de compra
        ekpo. "Item do documento de compras

TYPES: BEGIN OF ty_ekko, "Estrutura de Cabeçalho do documento de compra
  ebeln TYPE ekko-ebeln, "Número do Documento de Compras
  bukrs TYPE ekko-bukrs, "Empresa
  aedat TYPE ekko-aedat, "Data de Criação do Registro
  lifnr TYPE ekko-lifnr, "Número Fornecedor
  ekorg TYPE ekko-ekorg, "Organização de Compras
  ekgrp TYPE ekko-ekgrp, "Grupo de Compradores
END OF ty_ekko.

DATA: t_ekko  TYPE STANDARD TABLE OF ty_ekko, "Tabela Interna de Cabeçalho do documento de compra
      ls_ekko TYPE ty_ekko.                   "Estrutura de Cabeçalho do documento de compra

TYPES: BEGIN OF ty_ekpo,          "Estrutura de Item do documento de compras
           ebeln TYPE ekpo-ebeln, "Número do Documento de Compras
           ebelp TYPE ekpo-ebelp, "Nº item do documento de compra
           matnr TYPE ekpo-matnr, "Nª do Material
           werks TYPE ekpo-werks, "Centro
         END OF ty_ekpo.

DATA: t_ekpo  TYPE TABLE OF ty_ekpo, "Tabela Interna de Item do documento de compras
      ls_ekpo TYPE ty_ekpo.          "Estrutura de Item do documento de compras

DATA: lv_count TYPE i.               "Contador para contar o número de produtos vendidos por empresa
DATA: lv_last_bukrs TYPE ekko-bukrs. "Variável para delimitar fim da contagem de produtos por empresa

TYPES: BEGIN OF ty_output, "Estrutura - Saída de Dados
  ebeln TYPE ebeln, "Número do Documento de Compras
  bukrs TYPE bukrs, "Empresa
  aedat TYPE aedat, "Data de Criação do Registro
  lifnr TYPE lifnr, "Número Fornecedor
  ekorg TYPE ekorg, "Organização de Compras
  ekgrp TYPE ekgrp, "Grupo de Compradores
  ebelp TYPE ebelp, "Nº item do documento de compra
  matnr TYPE matnr, "Nª do Material
  werks TYPE werks, "Centro
END OF ty_output.

DATA: t_output TYPE TABLE OF ty_output, "Tabela Interna - Saída de Dados
      ls_output TYPE ty_output.         "Estrutura - Saída de Dados

START-OF-SELECTION.

"Sub Rotinas
PERFORM get_data.     "Seleção de dados
PERFORM display_data. "Impressão de dados

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

"os pedidos onde o campo Tipo de Documento de Compras = ‘NB’, retornando os
*campos Número do Documento de Compras, Empresa, Data de criação do registro,
*Numero Fornecedor, Organização de Compras e Grupo de Compradores.

  SELECT ebeln, "Número do Documento de Compras
         bukrs, "Empresa
         aedat, "Data de Criação do Registro
         lifnr, "Número Fornecedor
         ekorg, "Organização de Compras
         ekgrp  "Grupo de Compradores
    FROM ekko   "De abeçalho do documento de compra
    INTO CORRESPONDING FIELDS OF TABLE @t_ekko "Em Tabela Interna - Cabeçalho do documento de compra
    WHERE bsart = 'NB'. "Onde Documento de Compras igual a NB

*selecionar na tabela EKPO apenas
*itens em que o campo Material iniciar por ‘T’, onde o Numero do Documento de Compras
*relaciona as duas tabelas, retornando os campos Numero do Documento de Compras,
*Nº item do documento de compra, Nº do material e Centro. Só imprimir pedidos que
*atendam a esta condição.

  SELECT ebeln,  "Número do Documento de Compras
         ebelp,  "Nº item do documento de compra
         matnr,  "Nª do Material
         werks   "Centro
      FROM ekpo  "Tabela Transparente - Item do documento de compras
      INTO TABLE @t_ekpo "Na Tabela Interna Cabeçalho do documento de compra
      FOR ALL ENTRIES IN @t_ekko
      WHERE ebeln = @t_ekko-ebeln
      AND matnr LIKE 'T%'. "Onde o nome do material começa por T.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

*Na impressão do resultado, efetuar uma quebra no relatório por empresa, onde
*deverá ser impresso a quantidade de pedidos encontrada para cada uma das empresas
*selecionadas.
*
*Imprimir os campos Numero do Documento de Compras, Empresa, Data de
*criação do registro, Numero Fornecedor, Organização de Compras e Grupo de
*Compradores, Nº item do documento de compra, Nº do material e Centro.

LOOP AT t_ekpo INTO ls_ekpo.
  READ TABLE t_ekko INTO ls_ekko WITH KEY ebeln = ls_ekpo-ebeln.
  IF sy-subrc = 0.
    "Enche a tabela de saída com os dados filtrados
    ls_output-ebeln = ls_ekpo-ebeln.
    ls_output-ebelp = ls_ekpo-ebelp.
    ls_output-matnr = ls_ekpo-matnr.
    ls_output-werks = ls_ekpo-werks.
    ls_output-bukrs = ls_ekko-bukrs.
    ls_output-aedat = ls_ekko-aedat.
    ls_output-lifnr = ls_ekko-lifnr.
    ls_output-ekorg = ls_ekko-ekorg.
    ls_output-ekgrp = ls_ekko-ekgrp.
    APPEND ls_output TO t_output.
  ENDIF.
ENDLOOP.

WRITE: / '--------------------------------------------------'.

"Ordena a Tabela de Saída por empresa.
SORT t_output BY bukrs.

"Inicializa as Variáveis
lv_last_bukrs = ''.
lv_count = 0.

"Impressão dos Dados
LOOP AT t_output INTO ls_output.
  IF lv_last_bukrs <> ls_output-bukrs.
    IF lv_last_bukrs <> ''.
      WRITE: / '--------------------------------------------------'.
      WRITE: / 'Empresa:', lv_last_bukrs, 'Quantidade de Pedidos:', lv_count.
      WRITE: / '--------------------------------------------------'.
      lv_count = 0.
    ENDIF.
    WRITE: / 'Empresa:', ls_output-bukrs. "Primeira linha escrita
    lv_last_bukrs = ls_output-bukrs.
  ENDIF.

  WRITE: / 'Número do Documento de Compras: ', ls_output-ebeln,
         / 'Data de Criação do Registro: ', ls_output-aedat,
         / 'Número Fornecedor: ', ls_output-lifnr,
         / 'Organização de Compras: ', ls_output-ekorg,
         / 'Grupo de Compradores: ', ls_output-ekgrp,
         / 'Nº item do documento de compra: ', ls_output-ebelp,
         / 'Nº do material: ', ls_output-matnr,
         / 'Centro: ', ls_output-werks.
  WRITE: / '--------------------------------------------------'.
  lv_count = lv_count + 1.
ENDLOOP.

IF lv_last_bukrs <> ''.
  WRITE: / '--------------------------------------------------'.
  WRITE: / 'Empresa:', lv_last_bukrs, 'Quantidade de Pedidos:', lv_count.
  WRITE: / '--------------------------------------------------'.
ENDIF.

ENDFORM.
