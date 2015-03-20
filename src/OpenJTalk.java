import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.security.InvalidParameterException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;

public class OpenJTalk {
	public static Map<String, String> dictionary;
	public static Map<String, String> voices;

	public static void main(String[] args) {
		// Load necessary dictionary and voice files
		//dictionary = loadDictionaries();
		//voices = loadVoices();

		//String v = "mei_normal";
		//speak(generateTTS("こちらはオープンジェーイトークのデモでございます。", v, "UTF-8"));

		// Voice Demo 0
		//speak(generateTTS("ユータローさんによって作られたオープンジェーイトークのジャバライブラリーのテストでございます。これで私のかわいい声がジャバでも使えるようになりました！", v, "UTF-8"));

		// Voice Demo 1
		//speak(generateTTS("最急降下法は、関数（ポテンシャル面）の傾き（一階微分）のみから、関数の最小値を探索する勾配法のアルゴリズムの一つ。勾配法としては最も単純であり、直接・間接にこのアルゴリズムを使用している場合は多い。尚、最急降下法の“最急”とは、最も急な方向に降下することを意味している。すなわち、収束の速さに関して言及しているわけではない（より速いアルゴリズムがあり得る）というわけです。", v, "UTF-8"));

		// Voice Demo 2
		//speak(generateTTS("厚生労働省によりますと２９日午前、西アフリカのシエラレオネに滞在歴のある東京・世田谷区の３０代の男性から３８度を超える熱があると保健所に連絡がありました。１日まで８日間シエラレオネに滞在し、２３日に成田空港に到着したということです。男性は現地でエボラ出血熱の患者と直接接触したことはないということですが、今月１７日遺体の埋葬に立ち会い遺体の入った袋に触れたことがあると説明しているということです。このため、厚生労働省は男性を東京・新宿区の指定医療機関に搬送するとともに採取した血液を国立感染症研究所に送って、念のため詳しい検査を行った結果、エボラウイルスは検出されなかったということです。男性は鼻に炎症が起きる急性副鼻腔炎と診断され、症状が回復しだい退院するということです。",v, "UTF-8"));

		// Voice Demo 3 - Very impressive articulation especially for a TTS
		// system...

		// TODO: Clear out all of the tmp files prior to execution of sound files.
		// TODO: Mess around with the parameters, and create more voice types... or even have a class to allow for messing around with the parameters.

		Properties param = new Properties();
		param.put("x", "UTF-8");
		param.put("m", "miku_alpha");
		param.put("a", "0.54"); // All Pass Constant
		param.put("r", "1.3"); 	// Speed
		param.put("g", "1.1"); 	// Volume
		//param.put("jf", "7.7");
	
		Properties mei_params = new Properties();
		mei_params.put("x", "UTF-8");
		mei_params.put("m", "mei_normal");
		
		//mei_params.put("jf", "2");

		speak(generateTTS("最急降下法は、関数（ポテンシャル面）の傾き（一階微分）のみから、関数の最小値を探索する勾配法のアルゴリズムの一つ。勾配法としては最も単純であり、直接・間接にこのアルゴリズムを使用している場合は多い。尚、最急降下法の“最急”とは、最も急な方向に降下することを意味している。すなわち、収束の速さに関して言及しているわけではない（より速いアルゴリズムがあり得る）というわけです。", mei_params));
	}

	public static void speak(String file_dir) {
		execute("play " + file_dir);
	}

	public static String generateTTS(String text, String VOICE,
			String DICTIONARY) {
		String UID = UUID.randomUUID().toString();
		dictionary = loadDictionaries();
		voices = loadVoices();

		String script_dir = generateScript(text, UID);
		String command = "open_jtalk -x " + dictionary.get(DICTIONARY) + " -m "
				+ voices.get(VOICE) + " -ow tmp/" + UID + ".wav " + script_dir;
		execute(command);

		return "tmp/" + UID + ".wav";
	}

	public static String generateTTS(String text, Properties param) {
		if (param.size() == 0 || (param.get("x") == null || param.get("m") == null)) throw new InvalidParameterException();
		
		String UID = UUID.randomUUID().toString();
		String script_dir = generateScript(text, UID);
		dictionary = loadDictionaries();
		voices = loadVoices();
		
		String command = "open_jtalk -x " + dictionary.get(param.get("x")) + " -m " + voices.get(param.get("m"));
		if (param.get("s") != null) command += " -s " + param.get("s");
		if (param.get("p") != null) command += " -p " + param.get("p");
		if (param.get("a") != null) command += " -a " + param.get("a");
		if (param.get("b") != null) command += " -b " + param.get("b");
		if (param.get("r") != null) command += " -r " + param.get("r");
		if (param.get("fm") != null) command += " -fm " + param.get("fm");
		if (param.get("u") != null) command += " -u " + param.get("u");
		if (param.get("jm") != null) command += " -jm " + param.get("jm");
		if (param.get("jf") != null) command += " -jf " + param.get("jf");
		if (param.get("g") != null) command += " -g " + param.get("g");
		
		command += " -ow tmp/" + UID + ".wav " + script_dir;
		
		execute(command);
		return "tmp/" + UID + ".wav";
	}

	private static Map<String, String> loadDictionaries() {
		Map<String, String> dic = new HashMap<String, String>();
		File f = new File("dictionary");
		for (File file : f.listFiles()) {
			if (file.isDirectory())
				dic.put(file.getName(), file.toString());
		}
		return dic;
	}

	private static Map<String, String> loadVoices() {
		Map<String, String> voice = new HashMap<String, String>();
		File f = new File("voices");
		for (File files : f.listFiles())
			if (files.isDirectory())
				for (File subfile : files.listFiles())
					if (subfile.isFile()
							&& subfile.toString()
									.replaceAll("^.*\\.([^.]+)$", "$1")
									.equals("htsvoice"))
						voice.put(
								subfile.getName().substring(0,
										subfile.getName().lastIndexOf('.')),
								subfile.getPath());
		return voice;
	}

	private static String generateScript(String text, String uid) {
		String tmp_dir = "tmp/" + uid + ".txt";
		PrintWriter writer = null;
		try {
			writer = new PrintWriter(tmp_dir, "UTF-8");
			writer.write(text);
		} catch (FileNotFoundException | UnsupportedEncodingException e) {
			e.printStackTrace();
		} finally {
			try {
				writer.close();
			} catch (Exception e) {
			}
		}
		return tmp_dir;
	}

	private static String execute(String command) {
		StringBuffer output = new StringBuffer();
		Process p;
		try {
			p = Runtime.getRuntime().exec(command);
			p.waitFor();
			BufferedReader reader = new BufferedReader(new InputStreamReader(
					p.getInputStream()));
			String line = "";
			while ((line = reader.readLine()) != null)
				output.append(line + "\n");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return output.toString();
	}
}
