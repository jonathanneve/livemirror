object dmREST: TdmREST
  OldCreateOrder = False
  Height = 274
  Width = 427
  object HTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8080
    OnCommandOther = HTTPServerCommandOther
    OnCommandGet = HTTPServerCommandGet
    Left = 40
    Top = 24
  end
end
