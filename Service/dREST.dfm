object dmREST: TdmREST
  OldCreateOrder = False
  Height = 274
  Width = 427
  object HTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 8080
    OnCommandGet = HTTPServerCommandGet
    Left = 40
    Top = 24
  end
end
