# Ämnestexter ("Kort om frågeområdet") - en per topic, visas överst på
# respektive flik i ui.R. Innehållet är redaktionellt och kommer direkt
# från Samhällsanalys (ursprungligen från den gamla Power BI-rapporten),
# inte från databasen - läggs därför i kod istället för att läsas ur
# `analys`-kolumnen i elevhalsa_data (som bara innehöll platshållartext).
#
# Namnen nedan ska matcha `topic`-kolumnen i databasen. Matchningen i
# elevhalsa_hamta_amnestext() är oberoende av "och" vs "&", kommatecken
# och mellanslag, så mindre stavningsskillnader mot den exakta
# topic-strängen spelar ingen roll.
#
# OBS: saknar ännu text för "Kropp, sexualitet & samtycke" - lägg till
# när den kommer.
ELEVHALSA_AMNESTEXTER <- list(
  "Ditt liv & din framtid" = c(
    paste(
      "<b>Livstillfredsställelse</b> är ett mått på psykiskt välbefinnande. Bland svenska skolbarn",
      "är den generellt hög, men ojämnt fördelad. Flickor rapporterar lägre livstillfredsställelse",
      "än pojkar, och nivån sjunker med åldern för båda könen. Barn med funktionsnedsättning, barn",
      "som bor med en förälder eller utan sina föräldrar, samt barn i familjer med sämre",
      "socioekonomiska villkor uppger lägre livstillfredsställelse. Sambandet gäller både faktiska",
      "materiella tillgångar och hur familjens situation upplevs i jämförelse med andra."
    ),
    paste(
      "I elevhälsoformuläret skattar elever sin livstillfredsställelse på en skala från 0 till 10,",
      "där 10 är ”Toppen”. Resultaten i Dalarna följer samma mönster som nationellt: flickor",
      "är mindre nöjda än pojkar och livstillfredsställelsen minskar med stigande ålder."
    ),
    paste(
      "<b>Framtidstro</b> handlar om optimism inför den egna framtiden. Forskning visar att",
      "optimister oftare försöker lösa problem snarare än undvika dem, vilket bidrar till bättre",
      "anpassning, mindre frustration och förbättrad hälsa. Positiv framtidstro stärks av socialt",
      "stöd från familj, vänner och skola, akademiska framgångar, sociokulturella faktorer och",
      "trygghet i närområdet. Den är vanligare bland yngre än äldre ungdomar. Enligt ELSA har en",
      "hög andel elever positiv framtidstro, med jämn könsfördelning och stabila nivåer mellan",
      "åldersgrupper."
    ),
    "<em>Källa: ELSA, Elevhälsodata Dalarna</em>"
  ),
  "Hälsa och välbefinnande" = c(
    paste(
      "De flesta barn och unga i Sverige är nöjda med livet och upplever sin hälsa som god.",
      "Enligt Folkhälsomyndighetens och WHO:s uppföljning av svenska skolbarns hälsovanor har",
      "andelen med hög livstillfredsställelse varit stabil under 2000-talet. Samtidigt har andelen",
      "som rapporterar psykosomatiska besvär ökat, särskilt bland 15-åriga flickor. Detta visar att",
      "god psykisk hälsa och nedsatt psykiskt välbefinnande kan förekomma samtidigt, och att",
      "sambandet mellan dem är komplext."
    ),
    paste0(
      "I Dalarna skattar en majoritet av barnen sin <b>hälsa</b> som god. Den totala andelen pojkar ",
      "som anger att de mår <em>bra</em> eller <em>mycket bra</em> ligger ganska stilla på en hög ",
      "nivå under skolåren. Däremot minskar andelen som uppger att de mår <em>mycket</em> bra med ",
      "stigande ålder. Bland flickor är utvecklingen tydligare i att andelen som mår <em>bra</em> ",
      "eller <em>mycket bra</em> minskar. Psykosomatiska besvär – som <b>huvudvärk, oro, ",
      "nedstämdhet</b> och <b>magont</b> – är generellt vanligare bland flickor och tenderar att ",
      "öka med åldern."
    ),
    paste(
      "Folkhälsomyndigheten har undersökt möjliga orsaker till ökningen av psykosomatiska besvär",
      "bland 13- och 15-åringar mellan 1985 och 2014. Troliga faktorer är brister i skolans",
      "funktion, vilket lett till försämrade skolresultat och ökad skolstress. Även de stigande",
      "utbildnings- och kompetenskraven på arbetsmarknaden lyfts fram som en bidragande orsak."
    ),
    paste(
      "<b>Munhälsan</b> bland barn i Sverige är generellt god, men skillnaderna mellan olika",
      "socioekonomiska grupper är tydliga. Socialstyrelsens analys av kariesförekomst hos barn i",
      "förskoleåldern visar att både födelseland och socioekonomiska faktorer har ett klart samband",
      "med risken för karies vid sex års ålder. Även i Dalarna syns denna ojämlikhet: barn i",
      "socioekonomiskt mer utsatta områden har högre förekomst av karies. Resultaten understryker",
      "vikten av hälsofrämjande och förebyggande insatser, särskilt riktade mot dessa områden. I",
      "elevhälsoformuläret får barn uppge om de <b>borstar tänderna</b> både morgon och kväll. Här",
      "framgår att barn i förskoleklass gör detta i högre utsträckning än äldre elever."
    )
  ),
  "Fritid och rörelse" = c(
    paste(
      "En strukturerad fritid är positiv för barns fysiska och psykiska hälsa. Det ökar barns",
      "skoltrivsel och förbättrar deras betyg och höjer intresset att studera vidare. Det förebygger",
      "även missbruk, kriminalitet och psykisk ohälsa."
    ),
    paste(
      "<b>Problem kopplade till ungas fritid</b> uppstår när unga upplever att deras fritid",
      "begränsas till en sådan grad att den upplevs som mindre meningsfull och inte kan fylla",
      "funktionen av till exempel nöje och avkoppling, möjlighet att lära sig nya saker, att",
      "uttrycka sin personlighet eller umgås med andra. Grupper som oftare, jämfört med",
      "majoriteten, upplever att deras möjligheter till en meningsfull fritid begränsas är unga som",
      "är födda i andra länder än Sverige, unga med funktionsnedsättning och unga hbtq-personer",
      "liksom unga i utsatta områden och glesbygd."
    ),
    paste(
      "För att få den dagliga dosen av fysisk aktivitet <b>står vardagens rörelser och aktiva",
      "transporter</b> för den viktigaste delen, men allt färre barn går eller cyklar till skolan.",
      "Användningen av aktiva skoltransporter påverkas av attityder samt, sociala och personliga",
      "faktorer. Föräldrars attityder och beteende är särskilt viktiga. Skolan och kommunen har en",
      "mycket viktig roll för att möjliggöra och bidra till att alla barn ges förutsättningar för",
      "daglig fysisk aktivitet under sin uppväxt. Spontana aktiviteter och den fysiska aktiviteten i",
      "vardagen underlättas om närmiljön ger tillgång till säkra gång- och cykelvägar, lekplatser,",
      "öppna ytor, skog och annan natur."
    ),
    paste(
      "Barn och ungas <b>användning av digitala medier</b> har både positiva och negativa effekter.",
      "Statens medieråd sammanfattar delar av kunskapsläget att vuxna först och främst bör",
      "intressera sig för vad barnet använder skärmen till och hur det verkar må. Samtidigt ses att",
      "den ökade skärmtiden bland unga har kopplats till ökat stillasittande, minskat socialt",
      "umgänge och ökad risk vid riskfaktorer för att utveckla psykisk ohälsa. Det är således",
      "viktigt att vuxenvärlden i än högre grad än idag säkerställer att de faktorer som främjar",
      "hälsa och välbefinnande etableras i barns och ungas liv."
    )
  ),
  "Matvanor" = c(
    paste(
      "<b>Regelbundna frukostvanor</b> är inte sällan en indikator på att man också äter en bra",
      "kost i övrigt. Med en bra frukost, som fyller på kroppens behov av energi efter en lång",
      "natt, hålls blodsockret på en bra nivå under förmiddagen så det blir lättare att motstå",
      "småätande. Goda frukostvanor minskar risken att utveckla fetma redan under ungdomen och i",
      "tidig vuxen ålder."
    ),
    paste(
      "Ungas frukostvanor <b>kopplar såväl till socioekonomisk bakgrund som till",
      "familjestruktur</b>. Förutom socioekonomisk bakgrund kopplar ungas frukostvanor även till",
      "familjestruktur. I en dansk studie från Skolbarns hälsovanor visades att barn som växer upp",
      "i hushåll med bara en vuxen har särskilt stor risk att utveckla oregelbundna frukostvanor.",
      "De matvanor man får under barn- och ungdomsåren följer ofta med in i vuxen ålder."
    ),
    paste(
      "<b>Hela kroppen fungerar bättre om man äter regelbundet</b> – frukost, lunch, middag och",
      "något bra mellanmål däremellan. Skollunchen har, enligt Livsmedelsverket, potential att vara",
      "ett betydelsefullt stöd för ökad skolprestation genom att påverka motivation, stämningsläge,",
      "kognitiv prestation och beteende i klassrummet. Det är särskilt viktigt för barn från hushåll",
      "där socioekonomiska eller andra faktorer påverkar hushållets möjligheter att ge barnet en",
      "näringsriktig kost. Det är viktigt att skollunchen förknippas med behagliga känslor och att",
      "måltidsmiljön, det sociala sammanhanget och måltidens kulinariska egenskaper ger en positiv",
      "förstärkning av måltidsupplevelsen. En stressande och otrygg miljö motiverar individen till",
      "att avsluta måltiden snabbt eller att inte äta alls."
    ),
    "<em>Källa: ELSA, Elevhälsodata Dalarna</em>"
  ),
  "Skola och arbetsmiljö" = c(
    paste(
      "Sambanden mellan <b>det sociala stödet från lärare och klasskamrater</b> och psykisk hälsa är",
      "starka. Goda relationer och ett känslomässigt stöd mellan lärare och elever gynnar elevernas",
      "välbefinnande och minskar risken för internaliserade problem samt problem med",
      "uppmärksamhet och hyperaktivitet, och är en bestämningsfaktor för elevens skolresultat.",
      "Socialt stöd från lärare och andra elever minskar även risken för olika riskbeteenden såsom",
      "alkoholanvändning och rökning."
    ),
    paste(
      "Skolinspektionen definierar i sin granskning ”Skolans arbete för att säkerställa studiero”",
      "begreppet ”studiero” som att eleverna genom undervisningen fokuserar på lärandet och att",
      "störande inslag minimeras. Faktorer som påverkar elevers upplevelse av trygghet och studiero",
      "i skolan är till exempel undervisningens innehåll och lärares ledarskap. Särskilt viktigt är",
      "det att läraren har kunskap om elevernas individuella förutsättningar och behov och anpassar",
      "undervisningen efter det."
    ),
    paste(
      "En viktig del i lärarens ledarskap är att skapa goda relationer i klassen. Även det",
      "kollegiala samarbetet har goda effekter i arbetet för ett bättre skolklimat. Det bidrar både",
      "till att utveckla undervisningen och till lärarnas relationer till enskilda elever."
    ),
    paste(
      "I senaste undersökningen av svenska skolbarns hälsovanor sågs <b>flera försämringar som rör",
      "skolgången och miljön i skolan.</b> Den upplevda skolstressen och kraven har ökat. Elevernas",
      "relationer till varandra hade försämrats och mobbningen hade ökat sedan föregående",
      "mätningar."
    ),
    paste(
      "En av de viktigaste hälsofrämjande funktionerna hos skolan är att ge barn och unga",
      "upplevelsen av en positiv färdighetsutveckling som i sin tur bildar grund för ökade",
      "livschanser. Att uppleva tiden i skolan som något värdefullt gynnar dessutom",
      "hälsofrämjande levnadsvanor, medan en negativ skolupplevelse ökar risken för ohälsosamma",
      "levnadsvanor och fysisk och psykisk ohälsa."
    ),
    "<em>Källa: ELSA, Elevhälsodata Dalarna</em>"
  ),
  "Trivsel och relationer" = c(
    paste(
      "<b>En varm och tydlig relation mellan barn och förälder</b> minskar risken för en rad olika",
      "hälsoproblem och riskbeteenden hos barnen. Relationen förälder-barn kan i sin tur påverkas",
      "av andra faktorer som rör föräldrarnas förutsättningar att utöva sitt föräldraskap. Det kan",
      "röra sig om sjukdom, missbruk, arbetslöshet, ekonomisk utsatthet, trångboddhet etc."
    ),
    paste(
      "De skillnader i hälsa som ses hos den vuxna befolkningen har inte sällan sin förklaring i de",
      "skillnader i uppväxtvillkor som finns mellan barn och unga. Från det gemensammas sida finns",
      "mycket att göra till exempel när det gäller säkerställa en god bebyggd miljö,",
      "välfungerande förskolor och skolor, försörjningsmöjligheter och bra tillgång till",
      "samhällsservice och en meningsfull fritid. Här ingår också att utveckla stöd för",
      "föräldraskapet, både riktat och generellt. De levnadsvanor som av olika anledningar",
      "grundläggs under barn- och ungdomsåren påverkar individens hälsa och hälsorelaterade",
      "beteenden i vuxen ålder."
    ),
    paste(
      "<b>Att bli utsatt för mobbing</b> handlar om att utsättas för kränkande handlingar avsedda",
      "att skada på något sätt, att handlingarna upprepas flera gånger och att den utsatte befinner",
      "sig i ett underläge gentemot mobbaren/mobbarna. Att bli mobbad påverkar livet på många sätt.",
      "Man kan känna sig väldigt ensam och utsatt och inte vilja gå till skolan och undvika",
      "situationer där de som mobbar kan vara. Många får fysiska besvär, som ont i huvudet eller",
      "magen och att man kan få svårt att koncentrera sig i skolarbetet. Pågår mobbningen under",
      "lång tid påverkas inte sällan självkänslan negativt."
    ),
    paste(
      "<b>Den som blir mobbad äger ett tolkningsföreträde</b>. Det innebär att det bara är den som",
      "mobbas som kan bestämma om den är mobbad. Inte sällan har den som leder mobbningen egna",
      "problem med olika former av inåtvända eller utagerande psykiska problem, somatiska symtom",
      "och en mer negativ framtidssyn."
    ),
    paste(
      "Riskfaktorer för mobbning är kopplade till skolklimat, lärarnas stöd till eleverna och",
      "lärarnas och skolans inställning till mobbning. Även skolans ledarskap och grundläggande",
      "värderingar är relaterade till förekomst av mobbning, liksom faktorer som är kopplade till",
      "familjen, föräldrarna och samspelet mellan barn och föräldrar."
    ),
    "<em>Källa: ELSA, Elevhälsodata Dalarna</em>"
  ),
  "ANDTS" = c(
    paste(
      "Sedan 80-talet har <b>andelen alkoholkonsumenter och mängden konsumerad alkohol bland",
      "svenska skolelever minskat kraftigt</b>. Men bland 9:e klassare som i CAN:s undersökningen",
      "för 2020 angett att de använt alkohol de senaste 12 månaderna, 48 % av flickorna och 38 %",
      "av pojkarna, ses en icke obetydlig andel som rapporterar olika",
      "<b>alkoholrelaterade problem</b>. De vanligaste problemen är att ha grälat, haft sönder",
      "saker eller kläder, eller att ha blivit fotad eller filmad i pinsam eller kränkande situation.",
      "Omkring en femtedel av eleverna uppgav vart och ett av dessa. Vanligare bland flickor än",
      "bland pojkar. Men vanligare bland pojkar, 18 %, än bland flickor, 10 %, att ha kört",
      "motorfordon i samband med alkoholkonsumtion."
    ),
    paste(
      "Unga som har en <b>hög eller frekvent alkoholkonsumtion</b> riskerar flera olika negativa",
      "konsekvenser såsom sämre impulskontroll, sämre skolprestationer samt en hög",
      "alkoholkonsumtion som vuxen. Alkoholbruk är den riskfaktor som bidrar mest till",
      "sjukdomsbördan bland ungdomar i Sverige."
    ),
    paste(
      "<b>Rökning bland barn och unga har, liksom bland vuxna, minskat kraftigt</b> de senaste",
      "decennierna för att på senare tid plana ut. De som röker började för det mesta innan de",
      "fyllde 18 år. En viktig orsak till att man börjar är om andra i omgivningen röker t.ex.",
      "föräldrar, lärare eller jämnåriga."
    ),
    paste(
      "Eftersom <b>barn och ungdomar har en lägre tröskel för att bli beroende</b> än vuxna och då",
      "beroendet är svårt att bryta är det viktigt att förhindra att unga börjar röka, eller på",
      "annat sätt börjar använda nikotin t.ex. som snus."
    ),
    paste(
      "Även <b>snusningen minskade under 00-talet</b> för att plana ut och numera öka igen. År 2021",
      "ställdes frågan om vitt snus (nikotinsnus) för första gången i CAN:s undersökningar. Nästan",
      "en femtedel av eleverna i årskurs 9 och en tredjedel av gymnasiet år 2 hade använt vitt snus",
      "någon gång. Snusning har inte samma allvarliga hälsoeffekter som rökning men studier visar",
      "att den som förbrukar minst en dosa snus per dag har 70 % ökad risk att utveckla typ 2",
      "diabetes. Det är samma riskökning som ses för den som röker ett paket cigaretter per dag."
    ),
    "<em>Källa: ELSA, Elevhälsodata Dalarna</em>"
  )
)

# Hämtar ämnestexten för en topic, oberoende av mindre skillnader i
# stavning ("och" vs "&", kommatecken, mellanslag) mot listan ovan.
elevhalsa_hamta_amnestext <- function(topic) {
  normalisera <- function(x) {
    x <- tolower(x)
    x <- gsub("&", "och", x, fixed = TRUE)
    x <- gsub(",", "", x, fixed = TRUE)
    x <- gsub("\\s+", " ", trimws(x))
    x
  }
  namn_norm <- normalisera(names(ELEVHALSA_AMNESTEXTER))
  traff <- which(namn_norm == normalisera(topic))
  if (length(traff) == 1) return(ELEVHALSA_AMNESTEXTER[[traff]])
  character(0)
}
