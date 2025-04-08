CLASS LHC_ZR_LOANMASTER DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrLoanmaster
        RESULT result.

     METHODS changeValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZrLoanmaster~changeValues.

    METHODS earlynumbering_loanmaster FOR NUMBERING
      IMPORTING entities FOR CREATE ZrLoanmaster.
ENDCLASS.

CLASS LHC_ZR_LOANMASTER IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

    METHOD changeValues.

        READ ENTITIES OF zr_loanmaster IN LOCAL MODE
          ENTITY ZrLoanmaster
          FIELDS ( LoanAmount InterestAmount )
          WITH CORRESPONDING #( keys )
          RESULT DATA(advlicenses).

        loop at advlicenses INTO DATA(exportline).
          MODIFY ENTITIES OF zr_loanmaster IN LOCAL MODE
            ENTITY ZrLoanmaster
            UPDATE
            FIELDS ( BalanceAmount TotalAmount ) WITH VALUE #( ( %tky = exportline-%tky
                          BalanceAmount = exportline-InterestAmount + exportline-LoanAmount
                          TotalAmount = exportline-InterestAmount + exportline-LoanAmount
                          ) ).

        ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_loanmaster.


    DATA: nr_number     TYPE cl_numberrange_runtime=>nr_number.
    DATA nextnumber TYPE zr_loanmaster-loanno.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<gate_entry_header>).

        DATA Lnm TYPE zr_loanmaster-loanno.

        SELECT loanno FROM zr_loanmaster
        ORDER BY loanno DESCENDING
        INTO TABLE @DATA(LastNo)
        UP TO 1 ROWS .

        LOOP AT LastNo INTO DATA(NextNum).
             Lnm = NextNum-LoanNo.
        ENDLOOP.

        IF sy-subrc = 0.
          nextnumber = CONV zr_loanmaster-loanno( |{ Lnm + 1 }| ).
        ELSE.
          nextnumber = '1000000001'.
        ENDIF.


        SHIFT nextnumber LEFT DELETING LEADING '0'.
    ENDLOOP.

    "assign Gate Entry no.
    APPEND CORRESPONDING #( <gate_entry_header> ) TO mapped-zrloanmaster ASSIGNING FIELD-SYMBOL(<mapped_gate_entry_header>).
    IF <gate_entry_header>-LoanNo IS INITIAL.
"      max_item_id += 10.
      <mapped_gate_entry_header>-LoanNo =  nextnumber.
    ENDIF.


  ENDMETHOD.

ENDCLASS.
