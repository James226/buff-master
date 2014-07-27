_G.BuffMaster.Views.Main.DisplayGroup = {
  Name          = "BuffMaster_Group",
  Template      = "CRB_TooltipSimple",
  UseTemplateBG = true,
  Picture       = true,
  Border        = true,
  PosSize  = { -100, 20, 100, 40, "TOPRIGHT" },
  Children = {
  	{
  		Name = "Status",
  		Text = "Test",
  		PosSize = { -30, -50, 60, 30, "CENTER" },
  		DT_CENTER	= true
    },
  },
}