$INCLUDE PROG.ADMIN INC_OPTIONS
$INCLUDE UNIVERSE.INCLUDE XML.H
SoapAction=''
      URL = 'https://ccxl.smc3.com/AdminManager/services/CarrierConnectXL'
      SMC.WEB.LICENSE.KEY="wgUtt72QRKw1"
      SMC.WEB.PASSWORD="lCKF1zBT"
      SMC.WEB.USERNAME="xl@smartfreightware.com"
           stat = protocolLogging('GBTEST',"ON",27)
      
       TODAY = OCONV(DATE(),'D4-')
      YEAR = TODAY[7,4]
      MONTH = TODAY[1,2]
      DAY = TODAY[4,2]
      shipmentDate = YEAR:'-':MONTH:'-':DAY:'T12:00:00.000Z'
      serviceType = 'ALL_AVAILABLE'
      terminalType = "DELIVERY":@VM:'PICKUP'
      serviceMethod = 'LTL'
      destination.countryCode ='USA'
      origin.countryCode ='USA'
      countryCode = destination.countryCode:@VM:origin.countryCode
      SCAC ='CNWY'
      destination.postalCode = 97230
      origin.postalCode =64014
      postalCode = destination.postalCode:@VM:origin.postalCode 
      SCAC.COUNT =1
     XML.REQUEST = ''
      XML.REQUEST := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://webservices.smc.com" xmlns:ter="http://terminalsbypostalcode.requests.objects.webservice.carrierconnect.smc.com">'
      XML.REQUEST := '<soapenv:Header>'
      XML.REQUEST := '<web:AuthenticationToken>'
      XML.REQUEST := '<web:licenseKey>':SMC.WEB.LICENSE.KEY:'</web:licenseKey>'
      XML.REQUEST := '<web:password>':SMC.WEB.PASSWORD:'</web:password>'
      XML.REQUEST := '<web:username>':SMC.WEB.USERNAME:'</web:username>'
      XML.REQUEST := '</web:AuthenticationToken>'
      XML.REQUEST := '</soapenv:Header>'
      XML.REQUEST := '<soapenv:Body>'
      XML.REQUEST := '<web:TerminalsByPostalCode>'
      XML.REQUEST := '<web:TerminalsByPostalCodeRequest>'
      XML.REQUEST := '<ter:arrayTerminalByPostalCode>'
      FOR SA = 1 TO SCAC.COUNT
         FOR X = 1 TO 2
            XML.REQUEST := '<ter:TerminalByPostalCode>'
            XML.REQUEST := '<ter:city xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>'
            XML.REQUEST := '<ter:countryCode>':countryCode<1,X>:'</ter:countryCode>'
            XML.REQUEST := '<ter:postalCode>':postalCode<1,X>:'</ter:postalCode>'
            XML.REQUEST := '<ter:SCAC>':SCAC:'</ter:SCAC>'
            XML.REQUEST := '<ter:serviceCode xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>'
            XML.REQUEST := '<ter:serviceMethod>':serviceMethod:'</ter:serviceMethod>'
            XML.REQUEST := '<ter:serviceType>':serviceType:'</ter:serviceType>'
            XML.REQUEST := '<ter:shipmentDate>':shipmentDate:'</ter:shipmentDate>'
            XML.REQUEST := '<ter:stateProvince xsi:nil="true" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"/>'
            XML.REQUEST := '<ter:terminalType>':terminalType<1,X>:'</ter:terminalType>'
            XML.REQUEST := '</ter:TerminalByPostalCode>'
         NEXT X
      NEXT SCAC.COUNT
      XML.REQUEST := '</ter:arrayTerminalByPostalCode>'
      XML.REQUEST := '</web:TerminalsByPostalCodeRequest>'
      XML.REQUEST := '</web:TerminalsByPostalCode>'
      XML.REQUEST := '</soapenv:Body>'
      XML.REQUEST := '</soapenv:Envelope>'
    
      DEBUG
      
      
      Ret = setHTTPDefault( "BUFSIZE" , 16384 )
      Ret = setHTTPDefault( "VERSION" , "1.1" )
       stat = setHTTPDefault("HEADERS","")
      stat = setHTTPDefault("HEADERS","Connection":@VM:"close")
      STAT = CREATESECURITYCONTEXT(Security_Context, "TLSv1.2")
      config=''
      STAT = ShowSecurityContext(Security_Context,config)
      hndRequest = ""
      
 SOAP.RET = SoapCreateRequest(URL , SoapAction , SoapReq)

  
   SOAP.RET = SoapCreateSecureRequest(URL , SoapAction , SoapReq, Security_Context)
  STATUS = soapSetRequestContent(SoapReq, XML.REQUEST, 1)
   SOAP.TIMEOUT =60000  
*
      

      stat = setHTTPDefault("HEADERS","")
      stat = setHTTPDefault("HEADERS","Connection":@VM:"close")
      * Set SOAP requst Content
    
   STATUS = SOAPSubmitRequest(SoapReq,SOAP.TIMEOUT,RESPONSE.HEADERS,RESPONSE.DATA,SOAP.STATUS)
     
 stat = protocolLogging('GBTEST',"OFF",27)
 
     
     
     