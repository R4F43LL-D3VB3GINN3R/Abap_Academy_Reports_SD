*&---------------------------------------------------------------------*
*& Report ZREPORT_ALV_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_alv_1.

TABLES: mkpf,  "Documento do Material
        mseg,  "Segmento de Documento - Material
        makt,  "Textos Breves de Material
        t001w, "Centros/Filiais
        t001l. "Depósitos

"-----------------------------------------------------------------------"

TYPES: BEGIN OF ty_mkpf, "Estrutura de Documento do Material
  mblnr TYPE mkpf-mblnr, "Número do documento do material
  mjahr TYPE mkpf-mjahr, "Ano do documento do material
  bldat TYPE mkpf-bldat, "Data no documento
END OF ty_mkpf.

DATA: t_mkpf TYPE STANDARD TABLE OF ty_mkpf WITH HEADER LINE,
      ls_mkpf LIKE LINE OF t_mkpf.

"------------------------------------------------

TYPES: BEGIN OF ty_mseg, "Segmento de Documento - Material
  mblnr TYPE mseg-mblnr, "Número do documento do material
  mjahr TYPE mseg-mjahr, "Ano do documento do material
  zeile TYPE mseg-zeile, "Item no documento do material
  bwart TYPE mseg-bwart, "Tipo de movimento (administração de estoques)
  matnr TYPE mseg-matnr, "Nº do material
  werks TYPE mseg-werks, "Centro
  lgort TYPE mseg-lgort, "Depósito
  dmbtr TYPE mseg-dmbtr, "Montante em moeda interna
  menge TYPE mseg-menge, "Quantidade
  meins TYPE mseg-meins, "Unidade de medida básica
END OF ty_mseg.

DATA: t_mseg TYPE TABLE OF ty_mseg WITH HEADER LINE,
      ls_mseg TYPE ty_mseg.

"------------------------------------------------

TYPES: BEGIN OF ty_makt, "Textos Breves de Material
  matnr TYPE makt-matnr, "Nº do material
  maktx TYPE makt-maktx, "Texto breve de material
END OF ty_makt.

DATA: t_makt TYPE STANDARD TABLE OF makt WITH HEADER LINE,
      ls_makt LIKE LINE OF t_makt.

"------------------------------------------------

TYPES: BEGIN OF ty_t001w, "Centros/Filiais
  werks TYPE t001w-werks, "Centro
  name1 TYPE t001w-name1, "Nome
END OF ty_t001w.

DATA: t_t001w TYPE STANDARD TABLE OF t001w WITH HEADER LINE,
      ls_t001w LIKE LINE OF t_t001w.

"------------------------------------------------

TYPES: BEGIN OF ty_t001l, "Depósitos
  werks TYPE t001l-werks, "Centro
  lgort TYPE t001l-lgort, "Depósito
  lgobe TYPE t001l-lgobe, "Descrição do depósito
END OF ty_t001l.

DATA: t_t001l TYPE STANDARD TABLE OF t001l WITH HEADER LINE,
      ls_t001l LIKE LINE OF t_t001l.

"------------------------------------------------

TYPES: BEGIN OF ty_output,          "Tabela de Saída
  mblnr          TYPE mkpf-mblnr,   "Número do documento do material
  mjahr          TYPE mkpf-mjahr,   "Ano do documento do material
  bldat          TYPE mkpf-bldat,   "Data no documento
  zeile          TYPE mseg-zeile,   "Item no documento do material
  bwart          TYPE mseg-bwart,   "Tipo de movimento (administração de estoques)
  matnr          TYPE mseg-matnr,   "Nº do material
  maktx          TYPE makt-maktx,   "Texto breve de material
  matnr_maktx    TYPE string,       "Nº do material / Texto breve de material
  werks          TYPE mseg-werks,   "Centro
  name1          TYPE t001w-name1,  "Nome
  werks_name1    TYPE string,       "Centro / Nome
  lgort          TYPE mseg-lgort,   "Depósito
  lgobe          TYPE t001l-lgobe,  "Descrição do depósito
  lgort_lgobe    TYPE string,       "Depósito / Descrição do Depósito
  meins          TYPE mseg-meins,   "Unidade de medida básica
  dmbtr          TYPE mseg-dmbtr,   "Montante em moeda interna
  menge          TYPE mseg-menge,   "Quantidade
  unit_val       TYPE p DECIMALS 2, "Valor Unitário
END OF ty_output.

DATA: t_output TYPE TABLE OF ty_output WITH HEADER LINE,
      ls_output TYPE ty_output.

"------------------------------------------------

"Escopo do ALV - Estrutura - Tabela Interna
DATA: it_fieldcat      TYPE slis_t_fieldcat_alv,
      wa_fieldcat      TYPE slis_fieldcat_alv.

"------------------------------------------------

"Título do ALV
DATA: lv_datenow    TYPE char10,   "Data Atual
      lv_hour       TYPE sy-uzeit, "Hora Atual
      lv_hour_str   TYPE string,   "Hora
      lv_minute_str TYPE string,   "Minuto
      lv_second_str TYPE string,   "Segundo
      lv_title      TYPE string,   "Título
      lv_supertitle TYPE char70.   "Título Concatenado

DATA: lv_time_str TYPE string. "String para receber strings de tempo concatenadas

lv_title = 'Relatório de Movimentação de Material'.
lv_hour = sy-uzeit. "Variável recebe hora atual no sistema.

" Separação da hora, minuto e segundo
lv_hour_str   = lv_hour+0(2).
lv_minute_str = lv_hour+2(2).
lv_second_str = lv_hour+4(2).

"Concatenando-os com ":" para formar o horário completo
CONCATENATE lv_hour_str ':' lv_minute_str ':' lv_second_str INTO lv_time_str.

"Função para formatar a data
CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
  EXPORTING
    date_internal = sy-datum
  IMPORTING
    date_external = lv_datenow.

"Juntando o título, a data e a hora
CONCATENATE lv_title lv_datenow lv_time_str INTO lv_supertitle SEPARATED BY ' / '.

"------------------------------------------------

*Definir parâmetros de entrada
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_mjahr TYPE mkpf-mjahr DEFAULT '2008'.
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

*Definir seleção de múltiplos valores para MBLNR e BWART dentro de um bloco
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_mblnr FOR mkpf-mblnr,
                s_bwart FOR mseg-bwart.
SELECTION-SCREEN END OF BLOCK b1.

"Processamento de Sub-Rotinas.
START-OF-SELECTION.

PERFORM get_data.  "Consultas SQL e alimentação de tabelas internas
PERFORM read_data. "Processamento de dados e alimentação da Tabela de Saída
PERFORM fcat.      "Criação do escopo ALV
PERFORM display.   "Exibição do Relatório ALV

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  "-------------------------------------------------------------------------------------------------------

  "Selecionar na tabela MKPF os campos MBLNR, MJAHR e BLDAT,
  "Onde MKPFMBLNR IN S_MBLNR e MKPF-MJAHR = P_MJAHR e MKPF-BLART = ‘WL’. Armazenar
  "registros na tabela interna T_MKPF.

  SELECT mblnr,    "Número do documento do material
         mjahr,    "Ano do documento do material
         bldat     "Data no documento
      FROM mkpf "Tabela Transparente - Documento do Material
      INTO CORRESPONDING FIELDS OF TABLE @t_mkpf "Tabela Interna do Documento do Material
      WHERE mblnr IN @s_mblnr "Onde "Número do documento do material está no range de s_mblnr
      AND mjahr = @p_mjahr.    "E Ano do documento do material está no parâmetro p_mjahr
      "AND blart = 'WL'.       "E Tipo de documento é igual a WL

  "------------------------------------------------

  "seleciona os campos especificados da tabela MSEG
  "relacionados à tabela interna T_MKPF e armazena os registros na tabela interna T_MSEG.

  SELECT mblnr, "Número do documento do material
         mjahr, "Ano do documento do material
         zeile, "Item no documento do material
         bwart, "Tipo de movimento (administração de estoques)
         matnr, "Nº do material
         werks, "Centro
         lgort, "Depósito
         dmbtr, "Montante em moeda interna
         menge, "Quantidade
         meins  "Unidade de medida básica
    FROM mseg   "Tabela Transparente - Segmento de Documento - Material
    INTO CORRESPONDING FIELDS OF TABLE @t_mseg "Tabela Interna Segmento de Documento - Material
    FOR ALL ENTRIES IN @t_mkpf  "Tabela Interna do Documento do Material
    WHERE mblnr = @t_mkpf-mblnr "Onde Número do documento do material é igual a Número do documento do material da Tabela Interna
      AND mjahr = @t_mkpf-mjahr "E Ano do documento do material é igual a Ano do documento do material da Tabela Interna
      AND bwart IN @s_bwart.    "E Tipo de movimento (administração de estoques) está na Variável de Tipo de movimento (administração de estoques)

  "------------------------------------------------

  "Seleciona os campos especificados da tabela MAKT
  "relacionados à tabela interna T_MSEG e armazena os registros na tabela interna T_MAKT.

  SELECT matnr, "Nº do material
         maktx  "Texto breve de material
    FROM makt   "Tabela Transparente - Textos Breves de Material
    INTO CORRESPONDING FIELDS OF TABLE @t_makt "Tabela Interna - Textos Breves de Material
    FOR ALL ENTRIES IN @t_mseg  "Relacionada com Tabela Interna Segmento de Documento - Material
    WHERE matnr = @t_mseg-matnr "Onde Nº do material é igual a Tabela Interna - Nº do material
      AND spras = @sy-langu.    "Onde Language Key é igual a System Language

  "------------------------------------------------

  "Seleciona os campos especificados da tabela T001W
  "relacionados à tabela interna T_MSEG e armazena os registros na tabela interna T_T001W.

    SELECT werks, "Centro
           name1  "Nome
      FROM t001w  "Centros/Filiais
      INTO CORRESPONDING FIELDS OF TABLE @t_t001w "Tabela Interna "Centros/Filiais
      FOR ALL ENTRIES IN @t_mseg   "Relacionada com Tabela Interna Segmento de Documento - Material
      WHERE werks = @t_mseg-werks. "Onde Centro é igual a Tabela Interna - Centro

  "------------------------------------------------

  "Seleciona os campos especificados da tabela T001L
  "relacionados à tabela interna T_MSEG e armazena os registros na tabela interna T_T001L.

    SELECT werks, "Centro
           lgort, "Depósito
           lgobe  "Descrição do depósito
      FROM t001l  "Depósitos
      INTO CORRESPONDING FIELDS OF TABLE @t_t001l "Tabela Interna - Depósitos
      FOR ALL ENTRIES IN @t_mseg  "Relacionada com Tabela Interna Segmento de Documento - Material
      WHERE werks = @t_mseg-werks "Onde Centro é igual a Tabela Interna - Centro
      AND lgort = @t_mseg-lgort.  "E Depósito é igual a Tabela Interna - Depósito

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_data .

  "Processamento
  LOOP AT t_mseg INTO ls_mseg.

    CLEAR: ls_output.

    ls_output-mblnr = ls_mseg-mblnr.
    ls_output-mjahr = ls_mseg-mjahr.
    ls_output-zeile = ls_mseg-zeile.
    ls_output-bwart = ls_mseg-bwart.
    ls_output-matnr = ls_mseg-matnr.
    ls_output-werks = ls_mseg-werks.
    ls_output-lgort = ls_mseg-lgort.
    ls_output-dmbtr = ls_mseg-dmbtr.
    ls_output-menge = ls_mseg-menge.
    ls_output-meins = ls_mseg-meins.

    READ TABLE t_mkpf INTO ls_mkpf WITH KEY mblnr = ls_mseg-mblnr mjahr = ls_mseg-mjahr.
    IF sy-subrc = 0.
      ls_output-bldat = ls_mkpf-bldat.
    ENDIF.

    READ TABLE t_makt INTO ls_makt WITH KEY matnr = ls_mseg-matnr.
    IF sy-subrc = 0.
      ls_output-maktx = ls_makt-maktx.
    ENDIF.

    READ TABLE t_t001w INTO ls_t001w WITH KEY werks = ls_mseg-werks.
    IF sy-subrc = 0.
      ls_output-name1 = ls_t001w-name1.
    ENDIF.

    READ TABLE t_t001l INTO ls_t001l WITH KEY werks = ls_mseg-werks lgort = ls_mseg-lgort.
    IF sy-subrc = 0.
      ls_output-lgobe = ls_t001l-lgobe.
    ENDIF.

    IF ls_mseg-menge NE 0.
      ls_output-unit_val = ls_mseg-dmbtr / ls_mseg-menge.
    ENDIF.

    " Concatenar o número do material e o texto breve
    CONCATENATE ls_output-matnr ls_output-maktx INTO ls_output-matnr_maktx SEPARATED BY ' - '.
    CONCATENATE ls_output-werks ls_output-name1 INTO ls_output-werks_name1 SEPARATED BY ' - '.
    CONCATENATE ls_output-lgort ls_output-lgobe INTO ls_output-lgort_lgobe SEPARATED BY ' - '.

    APPEND ls_output TO t_output.

    " Quebra de Linhas por mjahr
    SORT t_output BY mjahr.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fcat .

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 1.
  wa_fieldcat-fieldname = 'mblnr'.
  wa_fieldcat-key = 'X'.
  wa_fieldcat-hotspot = 'X'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Número do Documento'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 19. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 2.
  wa_fieldcat-fieldname = 'mjahr'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Ano'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 4. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 3.
  wa_fieldcat-fieldname = 'bldat'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Data'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 8. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 4.
  wa_fieldcat-fieldname = 'zeile'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Item'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 4. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 5.
  wa_fieldcat-fieldname = 'bwart'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Seguimento'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 10. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 6.
  wa_fieldcat-fieldname = 'matnr_maktx'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Num / Txt Breve'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 25. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 7.
  wa_fieldcat-fieldname = 'werks_name1'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Centro / Nome'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 25. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 8.
  wa_fieldcat-fieldname = 'lgort_lgobe'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Depósito / Desc'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 25. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 9.
  wa_fieldcat-fieldname = 'meins'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Unidade de Medida'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 17. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 10.
  wa_fieldcat-fieldname = 'dmbtr'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Val. Monetário Interno'.
  wa_fieldcat-do_sum = 'X'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 23. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 11.
  wa_fieldcat-fieldname = 'menge'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Quantidade'.
  wa_fieldcat-do_sum = 'X'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 10. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR wa_fieldcat.
  wa_fieldcat-col_pos = 12.
  wa_fieldcat-fieldname = 'unit_val'.
  wa_fieldcat-tabname = 't_output'.
  wa_fieldcat-seltext_m = 'Valor Unitário'.
  wa_fieldcat-do_sum = 'X'.
  wa_fieldcat-just = 'C'.
  wa_fieldcat-outputlen = 14. " Define a largura da coluna
  APPEND wa_fieldcat TO it_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
     EXPORTING
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
*     I_BUFFER_ACTIVE                   = ' '
      i_callback_program                = 'SY-REPID'
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  =
*     I_BACKGROUND_ID                   = ' '
      i_grid_title                      = lv_supertitle
*     I_GRID_SETTINGS                   =
*     IS_LAYOUT                         =
      it_fieldcat                       = it_fieldcat
*     IT_EXCLUDING                      =
*     IT_SPECIAL_GROUPS                 =
*     IT_SORT                           =
*     IT_FILTER                         =
*     IS_SEL_HIDE                       =
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        =
*     IT_EVENTS                         =
*     IT_EVENT_EXIT                     =
*     IS_PRINT                          =
*     IS_REPREP_ID                      =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   =
*     IT_HYPERLINK                      =
*     IT_ADD_FIELDCAT                   =
*     IT_EXCEPT_QINFO                   =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER           =
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab                          = t_output
*   EXCEPTIONS
*     PROGRAM_ERROR                     = 1
*     OTHERS                            = 2
.

ENDFORM.
