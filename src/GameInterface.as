namespace GameInterface
{
	CControlContainer@ GetRoot()
	{
		auto playground = GetApp().CurrentPlayground;
		if (playground is null) {
			return null;
		}
		return playground.Interface.InterfaceRoot;
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
