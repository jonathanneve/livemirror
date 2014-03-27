dxgettext --delphi --useignorepo
msgmerge locale\FR\LC_MESSAGES\default.po default.po -U
dxgettext -b c:\projects\livemirror *.pas -o c:\projects\livemirror
msgmerge c:\projects\livemirror\common\locale\FR\LC_MESSAGES\common.po c:\projects\livemirror\common.po -U
