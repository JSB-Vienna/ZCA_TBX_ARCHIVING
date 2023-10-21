"! <p class="shorttext synchronized" lang="en">CA-TBX: Constants + value checks for archive content handler</p>
CLASS zcl_ca_c_archive_content DEFINITION PUBLIC
                                          CREATE PROTECTED.
* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   c o n s t a n t s
    CONSTANTS:
      "! <p class="shorttext synchronized" lang="en">Filter fields for ArchiveLink selections</p>
      BEGIN OF refresh_opt,
        "! <p class="shorttext synchronized" lang="en">'D' = Add delta only (= recently archived documents)</p>
        add_delta_only  TYPE char1 VALUE 'D' ##no_text,
        "! <p class="shorttext synchronized" lang="en">' ' = Return document buffer as it is</p>
        no_refresh      TYPE char1 VALUE abap_false ##no_text,
        "! <p class="shorttext synchronized" lang="en">'X' = Refresh buffer, destroy viewers and read again from DB</p>
        refresh_from_db TYPE char1 VALUE abap_true ##no_text,
      END OF refresh_opt,

      "! <p class="shorttext synchronized" lang="en">Filter fields for ArchiveLink selections</p>
      BEGIN OF al_filter,
        "! <p class="shorttext synchronized" lang="en">AL Filter param name for archiving date</p>
        arch_date TYPE fieldname VALUE 'AR_DATE' ##no_text,
        "! <p class="shorttext synchronized" lang="en">AL Filter param name for archive Id</p>
        arch_id   TYPE fieldname VALUE 'ARCHIV_ID' ##no_text,
        "! <p class="shorttext synchronized" lang="en">AL Filter param name for document class</p>
        doc_class TYPE fieldname VALUE 'DOC_TYPE' ##no_text,
        "! <p class="shorttext synchronized" lang="en">AL Filter param name for archive document Id</p>
        doc_id    TYPE fieldname VALUE 'ARC_DOC_ID' ##no_text,
        "! <p class="shorttext synchronized" lang="en">AL Filter param name for document type</p>
        doc_type  TYPE fieldname VALUE 'AR_OBJECT' ##no_text,
        "! <p class="shorttext synchronized" lang="en">AL Filter param name for technical field RESERVE</p>
        reserve   TYPE fieldname VALUE 'RESERVE' ##no_text,
      END OF al_filter,

      "! <p class="shorttext synchronized" lang="en">Filter fields for DMS selections</p>
      BEGIN OF dms_filter,
        "! <p class="shorttext synchronized" lang="en">DMS Filter param name for document number key</p>
        doc_id      TYPE fieldname VALUE 'DOCNO' ##no_text,
        "! <p class="shorttext synchronized" lang="en">DMS Filter param name for document part</p>
        doc_part    TYPE fieldname VALUE 'DOCTL' ##no_text,
        "! <p class="shorttext synchronized" lang="en">DMS Filter param name for document status</p>
        doc_state   TYPE fieldname VALUE 'DOKST' ##no_text,
        "! <p class="shorttext synchronized" lang="en">DMS Filter param name for document type</p>
        doc_type    TYPE fieldname VALUE 'DOKAR' ##no_text,
        "! <p class="shorttext synchronized" lang="en">DMS Filter param name for document version</p>
        doc_version TYPE fieldname VALUE 'DOKVR' ##no_text,
      END OF dms_filter.

*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Get instance</p>
      "!
      "! @parameter result | <p class="shorttext synchronized" lang="en">Class instance</p>
      get_instance
        RETURNING
          VALUE(result) TYPE REF TO zcl_ca_c_archive_content.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Valid ArchiveLink filter field name passed?</p>
      "!
      "! @parameter al_filter_field        | <p class="shorttext synchronized" lang="en">ArchiveLink filter field name</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling Archive content</p>
      is_al_filter_field_valid FINAL
        IMPORTING
          al_filter_field TYPE dxlocation
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Valid DMS filter field name passed?</p>
      "!
      "! @parameter dms_filter_field       | <p class="shorttext synchronized" lang="en">DMS filter field name</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling Archive content</p>
      is_dms_filter_field_valid FINAL
        IMPORTING
          dms_filter_field TYPE fieldname
        RAISING
          zcx_ca_archive_content.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   s t a t i c   a t t r i b u t e s
    CLASS-DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">Instance of the class itself</p>
      singleton_instance     TYPE REF TO zcl_ca_c_archive_content.

ENDCLASS.



CLASS zcl_ca_c_archive_content IMPLEMENTATION.

  METHOD get_instance.
    "-----------------------------------------------------------------*
    "   Get instance
    "-----------------------------------------------------------------*
    IF zcl_ca_c_archive_content=>singleton_instance IS NOT BOUND.
      zcl_ca_c_archive_content=>singleton_instance = NEW #( ).
    ENDIF.

    result = zcl_ca_c_archive_content=>singleton_instance.
  ENDMETHOD.                    "get_instance


  METHOD is_al_filter_field_valid.
    "-----------------------------------------------------------------*
    "   Valid ArchiveLink filter field name passed?
    "-----------------------------------------------------------------*
    IF al_filter_field NE al_filter-arch_date AND
       al_filter_field NE al_filter-arch_id   AND
       al_filter_field NE al_filter-doc_class AND
       al_filter_field NE al_filter-doc_id    AND
       al_filter_field NE al_filter-doc_type  AND
       al_filter_field NE al_filter-reserve.
      "Parameter '&1' has invalid value '&2'
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>param_invalid
          mv_msgty = 'E'
          mv_msgv1 = 'IV_AL_FILTER_FIELD'
          mv_msgv2 = CONV #( al_filter_field ) ##no_text.
    ENDIF.
  ENDMETHOD.                    "is_al_filter_field_valid


  METHOD is_dms_filter_field_valid.
    "-----------------------------------------------------------------*
    "   Valid DMS filter field name passed?
    "-----------------------------------------------------------------*
    IF dms_filter_field NE dms_filter-doc_id      AND
       dms_filter_field NE dms_filter-doc_part    AND
       dms_filter_field NE dms_filter-doc_state   AND
       dms_filter_field NE dms_filter-doc_type    AND
       dms_filter_field NE dms_filter-doc_version.
      "Parameter '&1' has invalid value '&2'
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>param_invalid
          mv_msgty = 'E'
          mv_msgv1 = 'IV_DMS_FILTER_FIELD'
          mv_msgv2 = CONV #( dms_filter_field ) ##no_text.
    ENDIF.
  ENDMETHOD.                    "is_dms_filter_field_valid

ENDCLASS.
