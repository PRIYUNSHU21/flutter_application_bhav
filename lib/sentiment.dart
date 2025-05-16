import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SentimentChartPage extends StatefulWidget {
  final List<String> userPrompts;

  const SentimentChartPage({Key? key, required this.userPrompts}) : super(key: key);

  @override
  _SentimentChartPageState createState() => _SentimentChartPageState();
}

class _SentimentChartPageState extends State<SentimentChartPage> {
  List<FlSpot> sentimentData = [];
  double minY = 0;
  double maxY = 0;
  String sentimentSummary = "Analyzing...";
  List<String> topPositiveWords = [];
  List<String> topNegativeWords = [];
  String warningMessage = "";

  @override
  void initState() {
    super.initState();
    performSentimentAnalysis(widget.userPrompts);
  }

  double analyzeSentiment(String text, Map<String, int> positiveWordCount, Map<String, int> negativeWordCount) {
    // Expanded sentiment dictionary including more English and Bengali words.
    final Map<String, double> sentimentScores = {
      // English Positive
      'love': 3, 'excellent': 3, 'amazing': 3, 'fantastic': 3, 'awesome': 3,
      'happy': 2, 'joy': 2, 'great': 2, 'positive': 2, 'success': 2, 'best': 2,
      'good': 1, 'nice': 1, 'wonderful': 3, 'incredible': 3, 'outstanding': 3,
      'satisfying': 2, 'pleased': 2, 'delightful': 3, 'brilliant': 3,
      'optimistic': 2, 'cheerful': 2,
      
      // English Neutral / Mild
      'okay': 0.5, 'fine': 0.5, 'average': 0.5,
      
      // English Negative
      'bad': -1, 'sad': -1, 'upset': -1, 'disappointed': -1,
      'terrible': -3, 'horrible': -3, 'awful': -3, 'hate': -3,
      'angry': -2, 'frustrated': -2, 'worst': -3,
      'disgusting': -3, 'unhappy': -2, 'miserable': -3, 'depressing': -3,
      'kill': -5, 'die': -5, 'suicide': -5, 'murder': -5,
      
      // Bengali Positive
      "আনন্দ": 7, "ভালো": 6, "সুখ": 7, "শান্তি": 6, "সুন্দর": 5, "মজা": 5, "প্রশংসা": 7, 
      "চমৎকার": 6, "অসাধারণ": 7, "সফল": 6, "উজ্জ্বল": 5, "প্রশান্তি": 6, "নির্ভরযোগ্য": 6, 
      "শক্তিশালী": 6, "সুখী": 7, "সন্তুষ্ট": 6, "বন্ধুত্বপূর্ণ": 5, "নির্ভীক": 6, "সৎ": 7, 
      "যত্নশীল": 6, "সহানুভূতিশীল": 6, "দয়ালু": 5, "উদ্যমী": 6, "উন্নত": 6, "বিশ্বস্ত": 7,
      "আশাবাদী": 6, "সৃজনশীল": 7, "সফলতা": 7, "ভদ্র": 5, "শ্রদ্ধাশীল": 6, "নিখুঁত": 7,
      "সাহসী": 6, "আকর্ষণীয়": 5, "আত্মবিশ্বাসী": 6, "উন্নয়নশীল": 5, "কৃতজ্ঞ": 7,
      
      // Bengali Negative
      "দুঃখ": -6, "কষ্ট": -5, "খারাপ": -6, "দুঃখজনক": -6, "বিরক্ত": -4, "রাগ": -5, "অপমান": -6,
      "লজ্জা": -5, "বিষণ্ণ": -6, "হতাশ": -6, "নিরাশ": -6, "অবহেলা": -5, "ধ্বংস": -7, 
      "বিরক্তিকর": -4, "নিন্দনীয়": -6, "ব্যথা": -6, "দুশ্চিন্তা": -5, "হতভম্ব": -4, 
      "অবমাননা": -6, "পাপ": -7, "লোভী": -5, "ভয়ঙ্কর": -6, "নির্যাতন": -7, "নিষ্ঠুর": -7,
      "মিথ্যাবাদী": -6, "প্রতারণা": -7, "নাশকতা": -7, "অবিশ্বাস": -5, "নির্লজ্জ": -6, 
      "দুর্নীতি": -7, "অজ্ঞতা": -5, "প্রতিশোধপরায়ণ": -6, "অশুভ": -7, "অভিশপ্ত": -6,
      "হিংসা": -6, "অত্যাচার": -7, "ভয়": -6, "আতঙ্ক": -7, "অবিশ্বাস্য": -5, "ব্যর্থতা": -6,
      "নিরাশা": -6, "হিংস্রতা": -7, "বিশৃঙ্খলা": -6, "বিপর্যয়": -7, "আত্মহত্যা": -7,
      "মৃত্যু": -7, "নিজেকে শেষ করা": -7, "মানসিক ভারসাম্যহীনতা": -6, "উন্মাদনা": -6, 
      "আত্মধ্বংসী": -7, "আত্মবিধ্বংসী চিন্তা": -7, "উন্মাদ": -6, "ভয়াবহ": -7, "অবসাদ": -6, 
      "নিরাশাগ্রস্ত": -6
    };

    double score = 0;
    // Split words using regex to handle punctuation.
    final words = text.toLowerCase().split(RegExp(r'[\s,.;!?]+'));

    for (var word in words) {
      if (sentimentScores.containsKey(word)) {
        double wordScore = sentimentScores[word]!;
        score += wordScore;

        if (wordScore > 0) {
          positiveWordCount[word] = (positiveWordCount[word] ?? 0) + 1;
        } else {
          negativeWordCount[word] = (negativeWordCount[word] ?? 0) + 1;
        }
      }
    }
    return score;
  }

  void performSentimentAnalysis(List<String> prompts) {
    Map<String, int> positiveWordCount = {};
    Map<String, int> negativeWordCount = {};

    List<double> sentimentScoresList = prompts
        .map((prompt) => analyzeSentiment(prompt, positiveWordCount, negativeWordCount))
        .toList();

    updateSentimentData(sentimentScoresList);
    updateSentimentSummary(sentimentScoresList, positiveWordCount, negativeWordCount);
  }

  void updateSentimentData(List<double> newSentiments) {
    setState(() {
      sentimentData = newSentiments
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
          .toList();

      if (newSentiments.isNotEmpty) {
        minY = newSentiments.reduce((a, b) => a < b ? a : b) - 1;
        maxY = newSentiments.reduce((a, b) => a > b ? a : b) + 1;
      } else {
        minY = -5;
        maxY = 5;
      }
    });
  }

  void updateSentimentSummary(List<double> scores, Map<String, int> positiveWordCount, Map<String, int> negativeWordCount) {
    double avgScore = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0;

    setState(() {
      sentimentSummary = avgScore > 1
          ? "Mostly Positive 😊"
          : avgScore < -1
              ? "Mostly Negative 😠"
              : "Neutral 😐";

      // If sentiment is extremely negative, show a warning.
      warningMessage = avgScore < -3
          ? "Warning: Extremely negative sentiment detected! Please consider seeking support."
          : "";

      topPositiveWords = extractTopWords(positiveWordCount);
      topNegativeWords = extractTopWords(negativeWordCount);
    });
  }

  List<String> extractTopWords(Map<String, int> wordCount) {
    var sortedEntries = wordCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(5).map((entry) => entry.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Sentiment Analysis Chart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sentiment Summary Card
            Card(
              color: const Color(0xFF1E1E1E),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      sentimentSummary,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: sentimentSummary.contains("Positive")
                            ? Colors.greenAccent
                            : sentimentSummary.contains("Negative")
                                ? Colors.redAccent
                                : Colors.amberAccent,
                      ),
                    ),
                    if (warningMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        warningMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chart Card
            Expanded(
              child: Card(
                color: const Color(0xFF1E1E1E),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (value) =>
                            FlLine(color: Colors.grey.shade700, strokeWidth: 0.5),
                        getDrawingVerticalLine: (value) =>
                            FlLine(color: Colors.grey.shade700, strokeWidth: 0.5),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: sentimentData,
                          isCurved: true,
                          color: const Color(0xFF8E24AA),
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                      ],
                      minY: minY,
                      maxY: maxY,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Top Words Section
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text(
                            "Top Positive Words",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topPositiveWords.join(', '),
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    color: const Color(0xFF1E1E1E),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text(
                            "Top Negative Words",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topNegativeWords.join(', '),
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Re-analyze Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF512DA8),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                performSentimentAnalysis(widget.userPrompts);
              },
              child: const Text(
                'Re-analyze Sentiment Data',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}