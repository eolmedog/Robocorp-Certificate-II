*** Settings ***
Documentation       Template robot main suite.

Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Browser.Selenium
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Robocorp.Vault
Library             RPA.Dialogs


*** Tasks ***
Minimal task
    ${csv_url}=    Read from vault
    Add text input    FormURL    label=Form URL    #https://robotsparebinindustries.com/#/robot-order
    ${form_url}=    Run Dialog
    Download and read csv    ${csv_url}[csv_url]
    Open URL    ${form_url.FormURL}
    Read and input data
    Create Zip file


*** Keywords ***
Download and read csv
    [Arguments]    ${urls}
    Download    ${urls}    overwrite=True

Open URL
    [Arguments]    ${urls}
    Open Available Browser    ${urls}
    Click Element    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[3]

Input an order
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    ${body}=    Catenate    SEPARATOR=    id-body-    ${order}[Body]
    Click Element    id:${body}
    Click Element    xpath://*[@id="root"]/div/div[1]/div/div[1]/form/div[3]/input
    Input Text    xpath://*[@id="root"]/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Click Element    address
    Input Text    address    ${order}[Address]
    Click Element    id:preview
    Wait Until Keyword Succeeds    10x    0.5 sec    Send Order
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    ${output_file}=    Catenate    receipt order    ${order}[Order number]    .pdf
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}PDFs${/}${output_file}
    ${output_img}=    Catenate    receipt order    ${order}[Order number]    .png
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${output_img}
    Open Pdf    ${OUTPUT_DIR}${/}PDFs${/}${output_file}
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}${output_img}
    ...    ${OUTPUT_DIR}${/}PDFs${/}${output_file}

    Click Element    id:order-another
    Click Element    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[3]

Send Order
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt

Read and input data
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${order}    IN    @{orders}
        TRY
            Input an order    ${order}
        EXCEPT
            LOG    Order ${order}[Order number] Failed
        END
    END

Create Zip file
    Archive Folder With Zip    ${OUTPUT_DIR}${/}PDFs    ${OUTPUT_DIR}${/}receipts.zip

Read from vault
    ${urls}=    Get Secret    urls
    RETURN    ${urls}
