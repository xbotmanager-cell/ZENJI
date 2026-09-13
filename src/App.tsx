import React from "react";
import { Download, MonitorPlay, Code2, Gamepad2 } from "lucide-react";

export default function App() {
  return (
    <div className="min-h-screen bg-neutral-950 text-neutral-100 flex flex-col items-center justify-center p-8 selection:bg-cyan-900 selection:text-white relative overflow-hidden">
      
      {/* Background decoration */}
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-neutral-900 via-neutral-950 to-black -z-10" />
      <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-cyan-900/10 rounded-full blur-[120px] mix-blend-screen pointer-events-none" />
      <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-red-900/10 rounded-full blur-[120px] mix-blend-screen pointer-events-none" />

      <main className="max-w-4xl w-full flex flex-col items-center gap-12 z-10">
        
        <header className="text-center space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-neutral-900/80 border border-neutral-800 text-sm font-medium text-cyan-400 mb-4 backdrop-blur-sm">
            <Code2 size={16} />
            <span>Godot 4.3 Engine Project Generated</span>
          </div>
          <h1 className="text-5xl md:text-7xl font-bold tracking-tight text-transparent bg-clip-text bg-gradient-to-br from-white to-neutral-400">
            Shadow Fighter
          </h1>
          <p className="text-lg text-neutral-400 max-w-2xl mx-auto">
            Your complete 2D cinematic silhouette fighting game has been built using procedural Godot structures. Ready for mobile deployment.
          </p>
        </header>

        <div className="grid md:grid-cols-3 gap-4 w-full">
          <FeatureCard 
            icon={<Gamepad2 className="text-red-400" />}
            title="Full Combat System"
            desc="Health, energy, blocking, knockbacks, screen shake, and combo tracking."
          />
          <FeatureCard 
            icon={<MonitorPlay className="text-cyan-400" />}
            title="Procedural Graphics"
            desc="Characters, effects, and arenas dynamically generated in-code."
          />
          <FeatureCard 
            icon={<Code2 className="text-emerald-400" />}
            title="Native GDScript"
            desc="Built purely in GDScript without external assets, optimized for Android."
          />
        </div>

        <div className="mt-8">
          <a 
            href="/api/download-godot" 
            className="group relative inline-flex items-center justify-center gap-3 px-8 py-4 bg-cyan-600 hover:bg-cyan-500 text-white font-bold rounded-full transition-all hover:scale-105 active:scale-95 shadow-[0_0_40px_-10px_rgba(8,145,178,0.5)] hover:shadow-[0_0_60px_-10px_rgba(8,145,178,0.7)]"
          >
            <Download size={24} className="group-hover:-translate-y-1 transition-transform" />
            <span>Download Godot Project (.zip)</span>
          </a>
        </div>

        <p className="text-neutral-500 text-sm text-center max-w-lg mt-8">
          Extract the zip file and open the folder in Godot Engine 4.3 or 4.7.1. Press <strong className="text-neutral-300">F5</strong> to launch the game on the Main Menu scene.
        </p>

      </main>
    </div>
  );
}

function FeatureCard({ icon, title, desc }: { icon: React.ReactNode; title: string; desc: string }) {
  return (
    <div className="flex flex-col items-start gap-3 p-6 rounded-2xl bg-neutral-900/50 border border-neutral-800 backdrop-blur-sm">
      <div className="p-3 bg-neutral-800 rounded-xl">
        {icon}
      </div>
      <h3 className="font-semibold text-neutral-200">{title}</h3>
      <p className="text-sm text-neutral-400 leading-relaxed">{desc}</p>
    </div>
  );
}
