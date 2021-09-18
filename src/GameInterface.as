namespace GameInterface
{
	CControlContainer@ GetRoot()
	{
		auto viewport = GetApp().Viewport;

		for (uint i = 0; i < viewport.Overlays.Length; i++) {
			auto overlay = viewport.Overlays[i];
			if (overlay.m_AdaptRatio != CHmsZoneOverlay::EHmsOverlayAdaptRatio::ShrinkToKeepRatio_OnlyWider) {
				continue;
			}

			auto sector = cast<CSceneSector>(overlay.UserData);
			if (sector is null || sector.Scene is null || sector.Scene.Mobils.Length == 0) {
				continue;
			}

			auto container = cast<CControlContainer>(sector.Scene.Mobils[0]);
			return cast<CControlContainer>(ControlFromID(container, "FrameInGameBase"));
		}

		return null;
	}

	CControlBase@ ControlFromID(CControlContainer@ container, const string &in id)
	{
		for (uint i = 0; i < container.Childs.Length; i++) {
			auto child = container.Childs[i];
			if (child.IdName == id) {
				return child;
			}
		}

		for (uint i = 0; i < container.Childs.Length; i++) {
			auto childContainer = cast<CControlContainer>(container.Childs[i]);
			if (childContainer is null) {
				continue;
			}

			auto ret = ControlFromID(childContainer, id);
			if (ret !is null) {
				return ret;
			}
		}

		return null;
	}
}
