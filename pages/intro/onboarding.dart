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
      "desc": "Temukan teknologi terbaru untuk menunjang aktivitasmu."
    },
    {
      "image": "lib/images/male-clothes-onboarding.webp",
      "title": "Fashion Pria & Wanita",
      "desc": "Tampil gaya dengan koleksi fashion pilihan terbaik."
    },
    {
      "image": "lib/images/female-shoes-onboarding.webp",
      "title": "Sepatu Berkualitas",
      "desc": "Langkah nyaman dengan berbagai pilihan sepatu hits."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            slides[index]['image']!, 
                            fit: BoxFit.cover,
                            errorBuilder: (c,e,s) => const Icon(Icons.image, size: 100, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(slides[index]['title']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 15),
                      Text(slides[index]['desc']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 8, width: currentIndex == index ? 20 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  if (currentIndex == slides.length - 1) {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => const Homepage())
                      );
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  }
                },
                child: Text(currentIndex == slides.length - 1 ? "Mulai Belanja" : "Lanjut", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}