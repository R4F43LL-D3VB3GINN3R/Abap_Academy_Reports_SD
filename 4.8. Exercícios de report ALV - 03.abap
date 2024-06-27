*&---------------------------------------------------------------------*
*& Report ZREPORT_ALV_3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zreport_alv_3.

TABLES: vbrk, vbak, vbrp, kna1, makt.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln,
                  s_fkdat FOR vbrk-fkdat.
      PARAMETERS: p_kunrg TYPE vbrk-kunrg.
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN SKIP 1.

SELECT vbeln, fkdat, kunrg
  INTO TABLE @DATA(t_vbrk)
  FROM vbrk
  WHERE vbeln IN @s_vbeln
    AND fkart = 'F2'
    AND fkdat IN @s_fkdat
    AND kunrg = @p_kunrg.
SELECT vbeln, posnr, matnr, fkimg, vrkme, netwr , aubel
    INTO TABLE @DATA(t_vbrp)
    FROM vbrp
    FOR ALL ENTRIES IN @t_vbrk
    WHERE vbeln = @t_vbrk-vbeln.
SELECT vbeln
  INTO TABLE @DATA(t_vbak)
  FROM vbak
  FOR ALL ENTRIES IN @t_vbrp
  WHERE vbeln = @t_vbrp-aubel.
SELECT kunnr, name1
  INTO TABLE @DATA(t_kna1)
  FROM kna1
  FOR ALL ENTRIES IN @t_vbrk
  WHERE kunnr = @t_vbrk-kunrg.
SELECT matnr, maktx
  INTO TABLE @DATA(t_makt)
  FROM makt
  FOR ALL ENTRIES IN @t_vbrp
  WHERE matnr = @t_vbrp-matnr
  AND spras = @sy-langu.

" Declaração de tipos de tabela de saída
TYPES: BEGIN OF ty_output,
         vbeln TYPE vbrk-vbeln,
         fkdat TYPE vbrk-fkdat,
         kunrg TYPE vbak-kunnr,
         posnr TYPE vbrp-posnr,
         matnr TYPE vbrp-matnr,
         fkimg TYPE vbrp-fkimg,
         vrkme TYPE vbrp-vrkme,
         netwr TYPE vbrp-netwr,
         aubel TYPE vbrp-aubel,
         name1 TYPE kna1-name1,
         maktx TYPE makt-maktx,
         status TYPE icon_d,  "Status do Semáforo
       END OF ty_output.

" Preenchimento da tabela de saída
DATA: ls_output TYPE ty_output,
      t_output type table of ty_output.

LOOP AT t_vbrk INTO DATA(ls_vbrk).
  CLEAR ls_output.
  ls_output-vbeln = ls_vbrk-vbeln.
  ls_output-fkdat = ls_vbrk-fkdat.
  ls_output-kunrg = ls_vbrk-kunrg.

  READ TABLE t_kna1 INTO DATA(ls_kna1) WITH KEY kunnr = ls_vbrk-kunrg.
  IF sy-subrc = 0.
    ls_output-name1 = ls_kna1-name1.
  ENDIF.

  LOOP AT t_vbrp INTO DATA(ls_vbrp) WHERE vbeln = ls_vbrk-vbeln.
    CLEAR ls_output.
    ls_output-vbeln = ls_vbrk-vbeln.
    ls_output-fkdat = ls_vbrk-fkdat.
    ls_output-kunrg = ls_vbrk-kunrg.
    ls_output-posnr = ls_vbrp-posnr.
    ls_output-matnr = ls_vbrp-matnr.
    ls_output-fkimg = ls_vbrp-fkimg.
    ls_output-vrkme = ls_vbrp-vrkme.
    ls_output-netwr = ls_vbrp-netwr.
    ls_output-aubel = ls_vbrp-aubel.

    READ TABLE t_makt INTO DATA(ls_makt) WITH KEY matnr = ls_vbrp-matnr.
    IF sy-subrc = 0.
      ls_output-maktx = ls_makt-maktx.
    ENDIF.

    READ TABLE t_vbak INTO DATA(ls_vbak) WITH KEY vbeln = ls_vbrp-aubel.
    IF sy-subrc = 0.
      APPEND ls_output TO t_output.
    ENDIF.
  ENDLOOP.
ENDLOOP.

DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_fieldcat TYPE slis_fieldcat_alv,
      ls_layout   TYPE slis_layout_alv.

* Construção do catálogo de campos
CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 1.
ls_fieldcat-fieldname = 'VBELN'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Número do Documento'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 19.
ls_fieldcat-ref_tabname = 'VBAK'.
ls_fieldcat-key = 'X'.
ls_fieldcat-hotspot = 'X'.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 2.
ls_fieldcat-fieldname = 'FKDAT'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Data'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 12.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 3.
ls_fieldcat-fieldname = 'POSNR'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Doc. Vendas'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 12.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 4.
ls_fieldcat-fieldname = 'KUNNR'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Cliente'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 24.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 5.
ls_fieldcat-fieldname = 'NETWR'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Valor Líquido'.
ls_fieldcat-do_sum = 'X'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 10.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 6.
ls_fieldcat-fieldname = 'MATNR'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Material'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 34.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 7.
ls_fieldcat-fieldname = 'AUBEL'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Número Documento (LIPS)'.
ls_fieldcat-just = 'C'.
ls_fieldcat-hotspot = 'X'.
ls_fieldcat-outputlen = 10.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 8.
ls_fieldcat-fieldname = 'GSBER_GTEXT'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Divisão'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 10.
APPEND ls_fieldcat TO lt_fieldcat.

CLEAR ls_fieldcat.
ls_fieldcat-col_pos = 9.
ls_fieldcat-fieldname = 'STATUS'.
ls_fieldcat-tabname = 'T_OUTPUT'.
ls_fieldcat-seltext_m = 'Status'.
ls_fieldcat-just = 'C'.
ls_fieldcat-outputlen = 15.
ls_fieldcat-icon = 'X'.
APPEND ls_fieldcat TO lt_fieldcat.

* Configuração do layout da ALV
ls_layout-colwidth_optimize = 'X'.
ls_layout-zebra = 'X'.
ls_layout-info_fieldname = 'STATUS'.

* Exibição dos dados na ALV
CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid
    it_fieldcat        = lt_fieldcat
    is_layout          = ls_layout
  TABLES
    t_outtab           = t_output.
