_G.BuffMaster.Views.ConfigWindow = {
  Name          = "BuffMasterConfig",
  Template      = "CRB_TooltipSimple",
  UseTemplateBG = true,
  Picture       = true,
  Border        = true,
  AnchorCenter  = { 500, 300 },
  Children = {
  	{
  		Name = "Status",
  		Text = "Test",
  		PosSize = { -30, -50, 60, 30, "CENTER" },
  		DT_CENTER	= true
    },
    {
      Name			= "CloseButton",
      WidgetType     = "PushButton",
      Base           = "CRB_UIKitSprites:btn_square_LARGE_Red",
      Text           = "Close Parent",
      TextThemeColor = "ffffffff", -- sets normal, flyby, pressed, pressedflyby, disabled to a color
      AnchorCenter   = { 150, 40 },

    },
  },
}