// sentiment.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'consult_specialist.dart';

// Enhanced Sentiment Analyzer
class EnhancedSentimentAnalyzer {
  static const Map<String, double> _sentimentDict = {
    // English - Positive
    'excellent': 3.0, 'amazing': 3.0, 'outstanding': 3.0, 'fantastic': 3.0,
    'wonderful': 2.5, 'great': 2.0, 'good': 1.5, 'nice': 1.0, 'okay': 0.5,
    'love': 3.0, 'adore': 2.5, 'like': 1.5, 'enjoy': 2.0, 'appreciate': 2.0,
    'happy': 2.0, 'joy': 2.5, 'excited': 2.5, 'pleased': 2.0, 'satisfied': 2.0,
    'calm': 1.5, 'peaceful': 2.0, 'relaxed': 1.5, 'comfortable': 1.5,
    'success': 2.5, 'achieve': 2.0, 'win': 2.0, 'perfect': 3.0, 'best': 2.5,
    
    // English - Negative  
    'terrible': -3.0, 'horrible': -3.0, 'awful': -3.0, 'disgusting': -3.0,
    'bad': -2.0, 'poor': -1.5, 'disappointing': -2.0, 'annoying': -1.5,
    'hate': -3.0, 'despise': -2.5, 'dislike': -1.5, 'upset': -2.0,
    'sad': -2.0, 'depressed': -2.5, 'angry': -2.5, 'frustrated': -2.0,
    'worried': -1.5, 'anxious': -2.0, 'stressed': -2.0, 'overwhelmed': -2.0,
    'worst': -3.0, 'fail': -2.0, 'failure': -2.5, 'lose': -1.5, 'lost': -1.5,
    
    // Mental health indicators (critical)
    'suicide': -5.0, 'kill myself': -5.0, 'end it all': -5.0, 'hopeless': -3.0,
    'worthless': -3.0, 'empty': -2.5, 'numb': -2.0, 'broken': -2.5,
    'death': -3.0, 'die': -4.0, 'dead': -3.0, 'murder': -5.0,
    
    // Bengali - Positive
    "আনন্দ": 3.0, "খুশি": 2.5, "ভালো": 2.0, "সুখ": 3.0, "শান্তি": 2.5,
    "সুন্দর": 2.0, "চমৎকার": 3.0, "অসাধারণ": 3.0, "দারুণ": 2.5, "মজা": 2.0,
    "ভালোবাসা": 3.0, "পছন্দ": 1.5, "আশা": 2.0, "স্বপ্ন": 1.5, "সফল": 2.5,
    "উন্নতি": 2.0, "প্রশংসা": 2.5, "গর্ব": 2.0, "আত্মবিশ্বাস": 2.0,
    "সন্তুষ্ট": 2.0, "প্রশান্তি": 2.5, "আরাম": 1.5, "নিরাপদ": 1.5,
    
    // Bengali - Negative
    "দুঃখ": -2.5, "কষ্ট": -2.5, "খারাপ": -2.0, "বিরক্ত": -2.0, "রাগ": -2.5,
    "হতাশ": -3.0, "নিরাশ": -3.0, "ভয়": -2.0, "চিন্তা": -1.5, "সমস্যা": -1.5,
    "ব্যথা": -2.0, "অসুস্থ": -1.5, "দুর্বল": -1.5, "ক্লান্ত": -1.0,
    "বিষণ্ণ": -2.5, "অবসাদ": -2.5, "হতভাগ্য": -2.5, "অভাগা": -2.0,
    "ব্যর্থ": -2.5, "পরাজয়": -2.0, "ক্ষতি": -2.0, "বিপদ": -2.5,
    
    // Critical Bengali terms
    "আত্মহত্যা": -5.0, "মরে যেতে চাই": -5.0, "শেষ করে দিতে চাই": -5.0,
    "বাঁচতে চাই না": -4.0, "মৃত্যু": -3.5, "মরণ": -3.5, "একা": -2.0,
    "নিঃসঙ্গ": -2.5, "অসহায়": -2.5, "নিরুপায়": -2.5,
  };

  static const List<String> _negationWords = [
    'not', 'no', 'never', 'neither', 'none', 'nobody', 'nothing', 'nowhere',
    'না', 'নেই', 'কখনো না', 'কিছু না', 'কেউ না', 'কোথাও না'
  ];

  static const List<String> _intensifiers = [
    'very', 'really', 'extremely', 'incredibly', 'absolutely', 'completely',
    'totally', 'quite', 'rather', 'pretty', 'fairly', 'highly',
    'খুব', 'অনেক', 'বেশি', 'একেবারে', 'অত্যন্ত', 'বিশেষভাবে'
  ];

  static SentimentResult analyzeSentiment(String text) {
    if (text.trim().isEmpty) {
      return SentimentResult(
        score: 0.0,
        label: 'Neutral',
        confidence: 0.0,
        riskLevel: RiskLevel.low,
        details: 'Empty text'
      );
    }

    final cleanText = _preprocessText(text);
    final words = cleanText.split(RegExp(r'\s+'));
    
    double score = 0.0;
    double wordCount = 0.0;
    int positiveWords = 0;
    int negativeWords = 0;
    List<String> detectedWords = [];
    bool hasNegation = false;
    bool hasIntensifier = false;
    double intensifierMultiplier = 1.0;

    for (int i = 0; i < words.length; i++) {
      final word = words[i].toLowerCase();
      
      if (_negationWords.contains(word)) {
        hasNegation = true;
        continue;
      }
      
      if (_intensifiers.contains(word)) {
        hasIntensifier = true;
        intensifierMultiplier = 1.5;
        continue;
      }
      
      if (_sentimentDict.containsKey(word)) {
        double wordScore = _sentimentDict[word]!;
        
        if (hasNegation) {
          wordScore *= -0.8;
          hasNegation = false;
        }
        
        if (hasIntensifier) {
          wordScore *= intensifierMultiplier;
          hasIntensifier = false;
          intensifierMultiplier = 1.0;
        }
        
        score += wordScore;
        wordCount++;
        detectedWords.add(word);
        
        if (wordScore > 0) positiveWords++;
        else if (wordScore < 0) negativeWords++;
      }
    }

    final normalizedScore = wordCount > 0 ? score / wordCount : 0.0;
    final result = _calculateSentimentLabel(normalizedScore, positiveWords, negativeWords);
    final riskLevel = _assessRisk(text, normalizedScore, detectedWords);
    
    return SentimentResult(
      score: normalizedScore,
      label: result['label'],
      confidence: result['confidence'],
      riskLevel: riskLevel,
      details: 'Analyzed ${detectedWords.length} sentiment words'
    );
  }

  static String _preprocessText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u0980-\u09FF]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Map<String, dynamic> _calculateSentimentLabel(double score, int pos, int neg) {
    double confidence = 0.5;
    String label = 'Neutral';
    
    if (score.abs() > 2.5) confidence = 0.9;
    else if (score.abs() > 1.5) confidence = 0.8;
    else if (score.abs() > 0.5) confidence = 0.7;
    else if (score.abs() > 0.1) confidence = 0.6;
    
    if (score >= 1.5) label = 'Very Positive';
    else if (score >= 0.5) label = 'Positive';
    else if (score <= -1.5) label = 'Very Negative';
    else if (score <= -0.5) label = 'Negative';
    else label = 'Neutral';
    
    return {'label': label, 'confidence': confidence};
  }

  static RiskLevel _assessRisk(String text, double score, List<String> words) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('suicide') || 
        lowerText.contains('kill myself') || 
        lowerText.contains('আত্মহত্যা') ||
        lowerText.contains('মরে যেতে চাই') ||
        lowerText.contains('বাঁচতে চাই না')) {
      return RiskLevel.critical;
    }
    
    if (score <= -2.5 && words.length >= 2) return RiskLevel.high;
    if (score <= -1.5) return RiskLevel.medium;
    return RiskLevel.low;
  }
}

class SentimentResult {
  final double score;
  final String label;
  final double confidence;
  final RiskLevel riskLevel;
  final String details;

  SentimentResult({
    required this.score,
    required this.label,
    required this.confidence,
    required this.riskLevel,
    required this.details,
  });
}

enum RiskLevel { low, medium, high, critical }

class SentimentChartPage extends StatefulWidget {
  final List<String> userPrompts;

  const SentimentChartPage({Key? key, required this.userPrompts}) : super(key: key);

  @override
  _SentimentChartPageState createState() => _SentimentChartPageState();
}

class _SentimentChartPageState extends State<SentimentChartPage> {
  List<FlSpot> sentimentData = [];
  List<SentimentResult> sentimentResults = [];
  String overallSentiment = "Analyzing...";
  RiskLevel overallRiskLevel = RiskLevel.low;

  @override
  void initState() {
    super.initState();
    performEnhancedSentimentAnalysis(widget.userPrompts);
  }

  void performEnhancedSentimentAnalysis(List<String> prompts) {
    if (prompts.isEmpty) {
      setState(() {
        overallSentiment = "No data to analyze";
      });
      return;
    }

    List<SentimentResult> results = prompts
        .map((prompt) => EnhancedSentimentAnalyzer.analyzeSentiment(prompt))
        .toList();

    setState(() {
      sentimentResults = results;
      sentimentData = results
          .asMap()
          .entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.score))
          .toList();
      
      _updateOverallAnalysis(results);
    });
  }

  void _updateOverallAnalysis(List<SentimentResult> results) {
    if (results.isEmpty) return;

    double avgScore = results.map((r) => r.score).reduce((a, b) => a + b) / results.length;
    double avgConfidence = results.map((r) => r.confidence).reduce((a, b) => a + b) / results.length;
    
    RiskLevel highestRisk = results
        .map((r) => r.riskLevel)
        .reduce((a, b) => a.index > b.index ? a : b);

    setState(() {
      overallRiskLevel = highestRisk;
      
      if (avgScore >= 1.0) {
        overallSentiment = "Overall Very Positive 😊 (${(avgConfidence * 100).round()}% confidence)";
      } else if (avgScore >= 0.3) {
        overallSentiment = "Overall Positive 🙂 (${(avgConfidence * 100).round()}% confidence)";
      } else if (avgScore <= -1.0) {
        overallSentiment = "Overall Very Negative 😢 (${(avgConfidence * 100).round()}% confidence)";
      } else if (avgScore <= -0.3) {
        overallSentiment = "Overall Negative 😕 (${(avgConfidence * 100).round()}% confidence)";
      } else {
        overallSentiment = "Overall Neutral 😐 (${(avgConfidence * 100).round()}% confidence)";
      }
    });
  }

  Widget _buildRiskLevelCard() {
    if (overallRiskLevel == RiskLevel.low) return const SizedBox.shrink();

    Color cardColor;
    String title;
    String message;
    IconData icon;

    switch (overallRiskLevel) {
      case RiskLevel.critical:
        cardColor = Theme.of(context).colorScheme.error;
        title = "🚨 Critical Mental Health Alert";
        message = "We detected concerning language. Please consider reaching out for professional support immediately.";
        icon = Icons.emergency;
        break;
      case RiskLevel.high:
        cardColor = Colors.orange.shade700;
        title = "⚠️ High Risk Detected";
        message = "Your messages show significant distress. Consider talking to a mental health professional.";
        icon = Icons.warning;
        break;
      case RiskLevel.medium:
        cardColor = Colors.yellow.shade700;
        title = "💛 Moderate Concern";
        message = "Some negative patterns detected. Self-care and support might be helpful.";
        icon = Icons.info;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (overallRiskLevel == RiskLevel.critical) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConsultSpecialistPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text("Get Immediate Help"),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: cardColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceLegend(String label, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
        Text(
          range,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Enhanced Sentiment Analysis',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: Column(
        children: [
          // Risk Level Alert Card
          _buildRiskLevelCard(),
          
          // Overall sentiment card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                overallSentiment,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Enhanced chart with confidence indicators
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: sentimentData.isEmpty
                    ? Center(
                        child: Text(
                          'No sentiment data available',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              strokeWidth: 0.5,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              strokeWidth: 0.5,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                                    'M${value.toInt() + 1}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: sentimentData,
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  final confidence = sentimentResults.isNotEmpty && 
                                                   index < sentimentResults.length
                                      ? sentimentResults[index].confidence
                                      : 0.5;
                                  
                                  return FlDotCirclePainter(
                                    radius: 4 + (confidence * 4),
                                    color: confidence > 0.8 
                                        ? Colors.green 
                                        : confidence > 0.6 
                                          ? Colors.orange 
                                          : Colors.red,
                                    strokeColor: Theme.of(context).colorScheme.surface,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                          ],
                          minY: sentimentData.isNotEmpty 
                              ? sentimentData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 1
                              : -3,
                          maxY: sentimentData.isNotEmpty 
                              ? sentimentData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1
                              : 3,
                        ),
                      ),
              ),
            ),
          ),
          
          // Confidence legend
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildConfidenceLegend('High', Colors.green, '80%+'),
                  _buildConfidenceLegend('Medium', Colors.orange, '60-80%'),
                  _buildConfidenceLegend('Low', Colors.red, '<60%'),
                ],
              ),
            ),
          ),
          
          // Re-analyze Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () {
                performEnhancedSentimentAnalysis(widget.userPrompts);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Re-analyze Sentiment Data'),
            ),
          ),
        ],
      ),
    );
  }
}
