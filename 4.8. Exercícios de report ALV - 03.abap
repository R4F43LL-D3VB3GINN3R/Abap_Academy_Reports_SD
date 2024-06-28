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

DATA: lv_count TYPE i.

TYPES: BEGIN OF ty_vbrk, "Estrutura - Documento de Faturamento: Dados de Cabeçalho
  vbeln TYPE vbrk-vbeln, "Número Fatura
  fkdat TYPE vbrk-fkdat, "Data Criação
  kunrg TYPE vbrk-kunrg, "Pagador
END OF ty_vbrk.

DATA: t_vbrk  TYPE TABLE OF ty_vbrk, "Tabela Interna - Documento de Faturamento: Dados de Cabeçalho
      ls_vbrk TYPE ty_vbrk.          "Estrutura - Documento de Faturamento: Dados de Cabeçalho

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln,                     "Número Fatura
                  s_fkdat FOR vbrk-fkdat.                     "Data Criação
      PARAMETERS: p_kunrg TYPE vbrk-kunrg DEFAULT 0017100001. "Pagador
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

START-OF-SELECTION.
  PERFORM doc_faturas.
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

  IF sy-subrc = 0.
    lv_count = lines( t_vbrk ). "Conta a quantidade de registros na Tabela.
    cl_demo_output=>new( 'Documentos de Faturamento' )->write_data( t_vbrk )->write_text( |Total de registros encontrados: { lv_count }| )->display( ).
  ENDIF.

ENDFORM.

*Selecionar na tabela VBRP os campos VBELN, POSNR, MATNR , FKIMG,
*VRKME, NETWR e AUBEL, relacionados com T_VBRK, onde VBRP-VBELN = T_VBRKVBELN. Armazenar registros na tabela interna T_VBRP.
*Selecionar na tabela VBAK o campo VBELN, relacionados com T_VBRP, onde
*VBAK-VBELN = T_VBRP-AUBEL. Armazenar registros na tabela interna T_VBAK.
*Selecionar na tabela KNA1 os campos KUNNR e NAME1, relacionados com
*T_VBRK, onde KNA1-KUNNR = T_VBTK-KUNRG. Armazenar registros na tabela interna
*T_KNA1.
*Selecionar na tabela MAKT os campos MATNR e MAKTX, relacionados com
*T_VBRP, onde MAKT-MATNR = T_VBRP-MATNR e SPRAS = SY-LANGU. Armazenar
*registros na tabela interna T_MAKT.
*
*Processamento:
*Dar um loop na tabela interna T_VBRP.
*Ler a tabela interna T_VBRK, onde T_VBRP-VBELN = T_VBRK-VBELN. Se não
*encontrar o registro, ler o próximo da tabela interna T_VBRP.
*Ler a tabela interna T_VBAK, onde T_VBRP-AUBEL = T_VBAK-VBELN. Se não
*encontrar o registro, ler o próximo da tabela interna T_VBRP.
*Ler a tabela interna T_KNA1, onde T_KNA1-KUNNR = T_VBRK-KUNRG. Se não
*encontrar o registro, ler o próximo da tabela interna T_VBRP.
*Ler a tabela interna T_MAKT, onde T_VBRP-MATNR = T_MAKT-MATNR. Se não
*encontrar o registro, ler o próximo da tabela interna T_VBRP.
*Criar uma tabela Z com os mesmos campos do Layout do relatório.
*
*Layout Relatório :
*O relatório deverá imprimir os campos conforme regras abaixo:
*Efetuar quebra pelos campos da tabela de saída KUNRG/NAME1 e FKDAT.
*Os campos FKIMG e NETWR deverão possuir somatória.
*O campo AUBEL deverá possui HOTSPOT conforme parâmetros abaixo:
*SET PARAMETER ID ‘AUN’ FIELD SELFIELD-VALUE.
*CALL TRANSACTION ‘VA03’ AND SKIP FIRST SCREEN.
*O campo VBELN(VBRK) deverá possui HOTSPOT conforme parâmetros abaixo:
*SET PARAMETER ID ‘VF’ FIELD SELFIELD-VALUE.
*CALL TRANSACTION ‘VF03’ AND SKIP FIRST SCREEN.
*Criar 1 botão para gravar o registro selecionado na tabela Z.
*O campo status do relatório será um semáforo onde o registro, se inserido com
*sucesso na tabela Z terá o semáforo verde. Se já existir na tabela Z terá o semáforo
*vermelho.
*Pintar de vermelho o campo FKIMG se este < 10. Se maior pintar de Verde.
*Pintar de vermelho o campo NETWR se este < 1000. Se maior pintar de Verde.
*O cabeçalho do relatório, além do título, deverá ter a data (sy-datum) e a hora (syuzeit) de execução do mesmo.
