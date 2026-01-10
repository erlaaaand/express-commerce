import 'package:flutter/material.dart';
import 'package:kadaierland/pages/home/homepage.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  
  final List<Map<String, String>> slides = [
    {
      "image": "lib/images/gadget-onboarding.webp", 
      "title": "Gadget Terkini",
      "desc": "Temukan teknologi terbaru untuk menunjang aktivitas dan produktivitas sehari-hari"
    },
    {
      "image": "lib/images/male-clothes-onboarding.webp",
      "title": "Fashion Pria & Wanita",
      "desc": "Tampil percaya diri dengan koleksi fashion pilihan berkualitas tinggi"
    },
    {
      "image": "lib/images/female-shoes-onboarding.webp",
      "title": "Sepatu Berkualitas",
      "desc": "Langkah nyaman dengan berbagai pilihan sepatu trendi dan stylish"
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => const Homepage())
                    );
                  },
                  child: const Text(
                    "Lewati",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                slides[index]['image']!, 
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.image, 
                                    size: 100, 
                                    color: Colors.grey
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Title
                        Text(
                          slides[index]['title']!, 
                          style: const TextStyle(
                            fontSize: 26, 
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ), 
                          textAlign: TextAlign.center
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          slides[index]['desc']!, 
                          textAlign: TextAlign.center, 
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            height: 1.5,
                          )
                        ),
                        
                        const SizedBox(height: 60),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentIndex == index ? 28 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 30),
            
            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: Row(
                children: [
                  // Back Button (only show if not first page)
                  if (currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          _controller.previousPage(
                            duration: const Duration(milliseconds: 300), 
                            curve: Curves.easeIn
                          );
                        },
                        child: const Text(
                          "Kembali",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  
                  if (currentIndex > 0) const SizedBox(width: 16),
                  
                  // Next/Start Button
                  Expanded(
                    flex: currentIndex > 0 ? 1 : 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (currentIndex == slides.length - 1) {
                          Navigator.pushReplacement(
                            context, 
                            MaterialPageRoute(builder: (context) => const Homepage())
                          );
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300), 
                            curve: Curves.easeIn
                          );
                        }
                      },
                      child: Text(
                        currentIndex == slides.length - 1 ? "Mulai Belanja" : "Lanjut", 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}