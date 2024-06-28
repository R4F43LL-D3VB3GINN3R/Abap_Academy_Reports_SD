*&---------------------------------------------------------------------*
*& Report ZREPORT_ALV_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_alv_3.

TABLES: vbrk, "Tabela Transparente - Documento de Faturamento: Dados de Cabeçalho
        vbak, "Tabela Transparente - Documento de Vendas: Dados de Cabeçalho
        vbrp, "Tabela Transparente - Documento de Faturamento: Dados de Item
        kna1, "Tabela Transparente - Mestre de Clientes (Parte Geral)
        makt. "Tabela Transparente - Textos Breves de Material

"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"
"Variáveis - Estruturas - Tabelas

"-----------------------

DATA: lv_count TYPE i.

TYPES: BEGIN OF ty_vbrk, "Estrutura - Documento de Faturamento: Dados de Cabeçalho
    vbeln TYPE vbrk-vbeln, "Número Fatura
    fkdat TYPE vbrk-fkdat, "Data Criação
    kunrg TYPE vbrk-kunrg, "Pagador
END OF ty_vbrk.

DATA: t_vbrk  TYPE TABLE OF ty_vbrk, "Tabela Interna - Documento de Faturamento: Dados de Cabeçalho
      ls_vbrk TYPE ty_vbrk.          "Estrutura - Documento de Faturamento: Dados de Cabeçalho

"-----------------------

TYPES: BEGIN OF ty_vbrp, "Estrutura - Documento de Faturamento: Dados de Item
  vbeln TYPE vbrp-vbeln, "Número Fatura
  posnr TYPE vbrp-posnr, "Item do Documento de Faturamento
  matnr TYPE vbrp-matnr, "Número do Material
  fkimg TYPE vbrp-fkimg, "Quantidade Faturada Efetivamente
  vrkme TYPE vbrp-vrkme, "Unidade de Venda
  netwr TYPE vbrp-netwr, "Valor Líquido do Item de Faturamento em Moeda do Documento
  aubel TYPE vbrp-aubel, "Documento de Vendas
END OF ty_vbrp.

DATA: t_vbrp  TYPE TABLE OF ty_vbrp, "Tabela Interna - Documento de Faturamento: Dados de Item
      ls_vbrp TYPE ty_vbrp.          "Estrutura - Documento de Faturamento: Dados de Item

"-----------------------

TYPES: BEGIN OF ty_vbak, "Estrutura - Documento de Vendas: Dados de Cabeçalho
  vbeln TYPE vbak-vbeln, "Documento de Vendas
  ernam type vbak-ernam, "Nome do Responsável que Adicionou o Objeto
END OF ty_vbak.

DATA: t_vbak  TYPE TABLE OF ty_vbak, "Tabela Interna - Documento de Vendas: Dados de Cabeçalho
      ls_vbak TYPE ty_vbak.          "Estrutura - Documento de Vendas: Dados de Cabeçalho

"-----------------------

TYPES: BEGIN OF ty_output,

  "Documento de Faturamento: Dados de Cabeçalho

    vbeln TYPE vbrk-vbeln, "Número Fatura
    fkdat TYPE vbrk-fkdat, "Data Criação
    kunrg TYPE vbrk-kunrg, "Pagador

  "Documento de Faturamento: Dados de Item

    posnr TYPE vbrp-posnr, "Item do Documento de Faturamento
    matnr TYPE vbrp-matnr, "Número do Material
    fkimg TYPE vbrp-fkimg, "Quantidade Faturada Efetivamente
    vrkme TYPE vbrp-vrkme, "Unidade de Venda
    netwr TYPE vbrp-netwr, "Valor Líquido do Item de Faturamento em Moeda do Documento
    aubel TYPE vbrp-aubel, "Documento de Vendas

  "Documento de Vendas: Dados de Cabeçalho

    ernam TYPE vbak-ernam,

END OF ty_output.

DATA: t_output  TYPE TABLE OF ty_output, "Tabela Interna - Tabela de Saída
      ls_output TYPE ty_output.          "Estrutura - Tabela de Saída

"-----------------------

"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"
"-------------------------------------------------------------------------------------------------------------------"

"---------------
"TELA DE SELEÇÃO
"---------------

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln,                     "Número Fatura
                  s_fkdat FOR vbrk-fkdat.                     "Data Criação
      PARAMETERS: p_kunrg TYPE vbrk-kunrg DEFAULT 0017100001. "Pagador
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

"Subroutines
START-OF-SELECTION.
  PERFORM doc_faturas.
  PERFORM doc_items.
  PERFORM doc_vendas.
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form doc_faturas
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM doc_faturas .

*Selecionar na tabela VBRK os campos VBELN, FKDAT e KUNRG, onde VBELN
*IN S_VBELN e FKART = ‘F2’ e FKDAT IN S_FKDAT e KUNRG = P_KUNRG.
*Armazenar registros na tabela interna T_VBRK.

    SELECT vbeln, "Selecione o Número Fatura
           fkdat, "Data Criação
           kunrg  "Pagador
           FROM vbrk "Da Tabela Transparente - Documento de Faturamento: Dados de Cabeçalho
           INTO CORRESPONDING FIELDS OF TABLE @t_vbrk "Nos campos correspondentes da Tabela Interna - Documento de Faturamento: Dados de Cabeçalho
           WHERE vbeln IN @s_vbeln "Onde o Número Fatura está no range de procura.
           AND fkart = 'F2' "E o Tipo Documento de Faturamento
           AND fkdat IN @s_fkdat "E a Data Criação é está no range de procura.
           AND kunrg = @p_kunrg. "E o Pagador for o selecionado pelo User.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form doc_items
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM doc_items .

*Selecionar na tabela VBRP os campos VBELN, POSNR, MATNR , FKIMG,
*VRKME, NETWR e AUBEL, relacionados com T_VBRK, onde VBRP-VBELN = T_VBRKVBELN. Armazenar registros na tabela interna T_VBRP.

*  Tabela VBRK                    Tabela VBRP
*  +---------+                   +---------+
*  | VBELN   |<------------------| VBELN   |
*  | FKDAT   |                   | POSNR   |
*  | KUNRG   |                   | MATNR   |
*  +---------+                   | FKIMG   |
*                                | VRKME   |
*                                | NETWR   |
*                                | AUBEL   |
*                                +---------+

  IF t_vbrk IS NOT INITIAL.
    SELECT vbeln, "Selecione o Número Fatura
           posnr, "Item do Documento de Faturamento
           matnr, "Número do Material
           fkimg, "Quantidade Faturada Efetivamente
           vrkme, "Unidade de Venda
           netwr, "Valor Líquido do Item de Faturamento em Moeda do Documento
           aubel  "Documento de Vendas
           FROM vbrp "Da Tabela Transparente - Documento de Faturamento: Dados de Item
           INTO CORRESPONDING FIELDS OF TABLE @t_vbrp "Nos campos correspondentes da Tabela Interna - Documento de Faturamento: Dados de Item
           FOR ALL ENTRIES IN @t_vbrk "Relacionaa à Tabela Interna - Documento de Faturamento: Dados de Cabeçalho
           WHERE vbeln = @t_vbrk-vbeln. "Onde partilham o mesmo Número da Fatura.

   "Preenche a Tabela de Saída.
    IF sy-subrc = 0.
      LOOP AT t_vbrk INTO ls_vbrk.
        CLEAR ls_output.
        LOOP AT t_vbrp INTO ls_vbrp WHERE vbeln = ls_vbrk-vbeln.
          MOVE-CORRESPONDING ls_vbrk TO ls_output.
          MOVE-CORRESPONDING ls_vbrp TO ls_output.
          APPEND ls_output TO t_output.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form doc_vendas
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM doc_vendas .

*Selecionar na tabela VBAK o campo VBELN, relacionados com T_VBRP, onde
*VBAK-VBELN = T_VBRP-AUBEL. Armazenar registros na tabela interna T_VBAK.

*+---------+                     +---------+                     +---------+
*|  VBRK   |                     |  VBRP   |                     |  VBAK   |
*|---------|                     |---------|                     |---------|
*| VBELN   |<--------------------| VBELN   |                     | VBELN   |
*| FKDAT   |                     | POSNR   |                     |         |
*| KUNRG   |                     | MATNR   |                     |         |
*|         |                     | FKIMG   |                     |         |
*|         |                     | VRKME   |                     |         |
*|         |                     | NETWR   |                     |         |
*|         |                     | AUBEL   |-------------------->|         |
*+---------+                     +---------+                     +---------+
*
*Tabela de Faturamento          Tabela de Itens                 Tabela de Vendas
*  (Cabeçalho)                   de Faturamento                  (Cabeçalho)
*
*Legenda:
*  - VBRK: Documento de Faturamento (Cabeçalho)
*  - VBRP: Documento de Faturamento (Itens)
*  - VBAK: Documento de Vendas (Cabeçalho)

  IF t_vbrp IS NOT INITIAL.
    SELECT vbeln,    "Selecione o Número Fatura
           ernam     "Nome do Cliente
           FROM vbak "Da Tabela Transparente - Documento de Vendas: Dados de Cabeçalho
           INTO CORRESPONDING FIELDS OF TABLE @t_vbak "Nos campos correspondentes da Tabela Interna - Documento de Vendas: Dados de Cabeçalho
           FOR ALL ENTRIES IN @t_vbrp "Relacionada à Tabela Interna - Documento de Faturamento: Dados de Item
           WHERE vbeln = @t_vbrp-aubel. "Onde os Documentos de Venda são os mesmos.

    "Preenche a Tabela de Saída.
    IF sy-subrc = 0.
      LOOP AT t_output INTO ls_output.
        LOOP AT t_vbak INTO ls_vbak WHERE vbeln = ls_output-aubel.
          ls_output-ernam = ls_vbak-ernam.
            MODIFY t_output FROM ls_output.
            CLEAR ls_output.
            CLEAR ls_vbak.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    " Remover linhas que tenham qualquer campo vazio
    LOOP AT t_output INTO ls_output.
      IF ls_output-vbeln  IS INITIAL OR
         ls_output-fkdat  IS INITIAL OR
         ls_output-kunrg  IS INITIAL OR
         ls_output-posnr  IS INITIAL OR
         ls_output-matnr  IS INITIAL OR
         ls_output-fkimg  IS INITIAL OR
         ls_output-vrkme  IS INITIAL OR
         ls_output-netwr  IS INITIAL OR
         ls_output-aubel  IS INITIAL OR
         ls_output-ernam  IS INITIAL.
        DELETE t_output INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    lv_count = lines( t_output ). "Conta a quantidade de registros na Tabela.
    cl_demo_output=>new( 'Documentos de Faturamento' )->write_data( t_output )->write_text( |Total de registros encontrados: { lv_count }| )->display( ).

  ENDIF.

ENDFORM.
