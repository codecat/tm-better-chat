// This data is just for debugging
namespace DummyData
{
	array<string> g_playerNames = {
		"TheChraz","Switch999","SapiTM","Thomas_Jean","Vojteek55","ACE.Donraii","AR_Mudda","ACE.Rasg","DarkBringer94","LyRooZ","twelfth-tm","L0udis","JanTM-","TheChraz","Scrapie98","EvonTM","solo23.","Novastxr","PauLL.4W","Bubbl3man","tm7ven","jkolt52","BarbosTM","Strykou","Carpenostra","AR_Down","Nico_TM","BerzerkTM","DBD.Norxus","Glast.BS","Dojip","Shpluk","Sardric","Numelops.Harry","BourbonKid3000","h3llomarcTwitch","Fixayte","PlaskTv","d0pemushrooms","bAd___cookie","entelech.","Striker96TM","Phil_6991","rattenjungexd","WinkyFace-","Tatauna.TTV","tim9367","ACE.Choum","Akulte_","Toad.TM","R00.","GranaDy.","KoIIektiv","Lostaussi","bozbez","Zenyy","GollumOfSparta","Saodineky","Argo--","Halo-TM","LorenziusTM","ClawzTM","MrTrolyMoly","DDR14","JussyDr","Vanity_TM","Ikarus.","Ta__Da","Kama_TM","NorthTM","Aynyxamer","RealRoyboi","flOwMEGALUL","Jaktorrr","hidefade","FFM.Jack.3","M1kw3","JaffaPadawan","xXHopelessX","Imot17","NuPrime_TM","SRK..","DacuberTM","QuantumDomino","Kattfot","F9.Marius89","lukario.TM","AffiTM","Linkcrafter","Shadow-TM","Nerms23","AreogonTM","neigh_sayer","keby..","Lemon.TM","Famajoe","r4diaxo","Grizi.link","AurisTFG","cacaproutman","Klowjoh.","ATrippyManeHDtv","Kaslacroute","Cinn007","Titlo77","Xades01","keyserman","Monkey.TM","Cemkoo","Neodym.TM","AstronomiaTM","scheyo95","tibiditope","xifos","Ludinxx","TDGatsby","ThomBern","Docker.","Zobalute","Biscione156","DubbyTM","kisyraa","mircheq","TFK.bonnie","Razii.","belingo46","LarryyTM","SuppenNoodle","M0NTI_91","Obitom.","FiTyruneeli","MASSAAA","Frich4x","Speedself","Cyptex","TheTekkForce","Zenitect","ShadowTM","MellowJA","Minimariner","Maverickwr13","Taeroyi","unreal1430","Eblouiis","Creative._.","Sam830_tm","Dog..","FiffousTM","chrisbirdie","Tocatone","Chadok","berniiiiiiiii","johannes-mk","KOTOR_Obi-Wan","Pato74ever","WagyuuBeef","shikamaru-","FrEEzR_TM","IdleTM","LokoGz_","MatP93","wh33lz2004","Hanzzq."
	};

	array<string> g_lipsum = {
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
		"Donec pellentesque eros ut luctus convallis.",
		"Pellentesque sodales ligula eu turpis blandit consectetur.",
		"Proin sodales libero ut leo sodales, sed sollicitudin tortor cursus.",
		"Phasellus at nibh ac sapien cursus vulputate ac sed mi.",
		"Vivamus lobortis lectus sed posuere fermentum.",
		"Mauris commodo erat et purus egestas, vel sagittis sapien accumsan.",
		"Quisque rhoncus nisl vel felis cursus ultrices.",
		"Nulla euismod velit et gravida consequat.",
		"Quisque a odio bibendum erat egestas rhoncus nec non erat.",
		"Vivamus porta ligula eget turpis congue facilisis.",
		"Fusce porta ipsum mattis, elementum neque ac, ultrices magna.",
		"Donec eget nibh sit amet urna sollicitudin varius.",
		"Sed pharetra tellus ut est vehicula faucibus.",
		"Phasellus vel diam vel neque cursus bibendum.",
		"Aenean semper nisl nec turpis tempus, sit amet elementum nulla laoreet.",
		"Nam ut erat bibendum, congue ligula ut, maximus est.",
		"Ut tempus sapien ut magna rutrum, a iaculis odio vulputate.",
		"Proin eget nibh non leo aliquet maximus malesuada vitae metus.",
		"Aenean ac ex a arcu malesuada egestas.",
		"Maecenas id risus a nisl varius vulputate.",
		"Pellentesque sed ex malesuada, efficitur nibh ac, maximus velit.",
		"In sed mi vehicula, sollicitudin tortor eu, mollis lacus.",
		"Ut vitae tortor sed dui sodales viverra consectetur non dolor.",
		"Donec pharetra lectus sit amet metus accumsan, sed tempor eros varius.",
		"Duis viverra leo dignissim diam consequat, vel vehicula leo vehicula.",
		"Nam non metus at enim luctus aliquet eget sit amet eros.",
		"Integer eleifend dui non aliquet vestibulum.",
		"Donec facilisis ex et magna egestas, vel auctor felis vestibulum.",
		"Aliquam nec neque mollis augue eleifend efficitur.",
		"Nunc eget sapien a risus commodo iaculis.",
		"Sed sit amet neque ac ex finibus dictum.",
		"Praesent eget nibh suscipit, rutrum metus aliquam, mollis dolor.",
		"Proin eget orci eget augue suscipit condimentum.",
		"Fusce pulvinar leo non vestibulum dignissim."
	};

	string PlayerName()
	{
		int index = Math::Rand(0, int(g_playerNames.Length));
		return g_playerNames[index];
	}

	string Lipsum()
	{
		int index = Math::Rand(0, int(g_lipsum.Length));
		return g_lipsum[index];
	}

	string FormattedColor()
	{
		string ret = "$";
		for (int i = 0; i < 3; i++) {
			ret += Text::Format("%x", Math::Rand(0, 0xF));
		}
		return ret;
	}
}
