@context(
  define(mod.sharedutils.glossary)
  file("game/gui/menus/glossary/glossaryBooksMenu.ws")
  at(class CR4GlossaryBooksMenu)
)

@insert(
  at(function PopulateData)
  above(m_flashValueStorage.SetFlashArray)
)
// sharedutils - glossary - BEGIN
SUG_populateListData(dataArray, m_flashValueStorage);
// sharedutils - glossary - END