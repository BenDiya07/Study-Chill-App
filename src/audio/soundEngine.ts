/**
 * Web Audio API procedural sound engine for Study Chill
 * Generates continuous soothing ambient textures and relaxing meditation chimes.
 */

class SoundEngine {
  private ctx: AudioContext | null = null;
  private masterGain: GainNode | null = null;
  private channelGains: Map<string, GainNode> = new Map();
  private channelNodes: Map<string, { stop: () => void }> = new Map();
  private isInitialized = false;

  private init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      this.ctx = new AudioCtx();
      this.masterGain = this.ctx.createGain();
      this.masterGain.gain.setValueAtTime(0.8, this.ctx.currentTime);
      this.masterGain.connect(this.ctx.destination);
      this.isInitialized = true;
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  public setMasterVolume(volume: number) {
    this.init();
    if (this.masterGain && this.ctx) {
      this.masterGain.gain.setTargetAtTime(Math.max(0, Math.min(1, volume)), this.ctx.currentTime, 0.05);
    }
  }

  public setChannelVolume(channelId: string, volume: number) {
    this.init();
    const gainNode = this.channelGains.get(channelId);
    if (gainNode && this.ctx) {
      gainNode.gain.setTargetAtTime(Math.max(0, Math.min(1, volume)), this.ctx.currentTime, 0.05);
    }
  }

  public startChannel(channelId: string, volume: number) {
    this.init();
    if (!this.ctx || !this.masterGain) return;

    // If already playing, just adjust volume
    if (this.channelNodes.has(channelId)) {
      this.setChannelVolume(channelId, volume);
      return;
    }

    const channelGain = this.ctx.createGain();
    channelGain.gain.setValueAtTime(volume, this.ctx.currentTime);
    channelGain.connect(this.masterGain);
    this.channelGains.set(channelId, channelGain);

    let stopper: () => void = () => {};

    switch (channelId) {
      case 'rain':
        stopper = this.createRainSound(channelGain);
        break;
      case 'coffee':
        stopper = this.createCoffeeShopSound(channelGain);
        break;
      case 'white_noise':
        stopper = this.createWhiteNoiseSound(channelGain);
        break;
      case 'campfire':
        stopper = this.createCampfireSound(channelGain);
        break;
      case 'forest':
        stopper = this.createForestSound(channelGain);
        break;
      case 'ocean':
        stopper = this.createOceanSound(channelGain);
        break;
      default:
        stopper = this.createWhiteNoiseSound(channelGain);
    }

    this.channelNodes.set(channelId, { stop: stopper });
  }

  public stopChannel(channelId: string) {
    const node = this.channelNodes.get(channelId);
    if (node) {
      node.stop();
      this.channelNodes.delete(channelId);
    }
    const gain = this.channelGains.get(channelId);
    if (gain && this.ctx) {
      gain.gain.setTargetAtTime(0, this.ctx.currentTime, 0.05);
      setTimeout(() => {
        gain.disconnect();
        this.channelGains.delete(channelId);
      }, 100);
    }
  }

  public playFinishChime() {
    this.init();
    if (!this.ctx || !this.masterGain) return;

    const now = this.ctx.currentTime;
    const chimeGain = this.ctx.createGain();
    chimeGain.gain.setValueAtTime(0.7, now);
    chimeGain.connect(this.masterGain);

    // Harmonic Tibetan singing bowl frequencies: 528Hz (Love/Focus), 1056Hz, 1584Hz
    const freqs = [528, 1056, 1584, 2112];
    const gains = [0.6, 0.25, 0.12, 0.05];

    freqs.forEach((freq, idx) => {
      if (!this.ctx) return;
      const osc = this.ctx.createOscillator();
      const oscGain = this.ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now);

      oscGain.gain.setValueAtTime(gains[idx], now);
      oscGain.gain.exponentialRampToValueAtTime(0.0001, now + 3.2);

      osc.connect(oscGain);
      oscGain.connect(chimeGain);

      osc.start(now);
      osc.stop(now + 3.5);
    });

    setTimeout(() => {
      chimeGain.disconnect();
    }, 3800);
  }

  // --- Procedural Sound Generators ---

  private createRainSound(dest: GainNode): () => void {
    if (!this.ctx) return () => {};
    const bufferSize = this.ctx.sampleRate * 2;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);

    // Pink noise generation
    let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;
      b0 = 0.99886 * b0 + white * 0.0555179;
      b1 = 0.99332 * b1 + white * 0.0750759;
      b2 = 0.96900 * b2 + white * 0.1538520;
      b3 = 0.86650 * b3 + white * 0.3104856;
      b4 = 0.55000 * b4 + white * 0.5329522;
      b5 = -0.7616 * b5 - white * 0.0168980;
      data[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.08;
      b6 = white * 0.115926;
    }

    const noiseSource = this.ctx.createBufferSource();
    noiseSource.buffer = buffer;
    noiseSource.loop = true;

    // Bandpass filter for gentle rain acoustics
    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(1400, this.ctx.currentTime);

    noiseSource.connect(filter);
    filter.connect(dest);
    noiseSource.start();

    return () => {
      try {
        noiseSource.stop();
        noiseSource.disconnect();
      } catch {
        // Safe discard
      }
    };
  }

  private createWhiteNoiseSound(dest: GainNode): () => void {
    if (!this.ctx) return () => {};
    const bufferSize = this.ctx.sampleRate * 2;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < bufferSize; i++) {
      data[i] = (Math.random() * 2 - 1) * 0.05;
    }

    const source = this.ctx.createBufferSource();
    source.buffer = buffer;
    source.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(2200, this.ctx.currentTime);

    source.connect(filter);
    filter.connect(dest);
    source.start();

    return () => {
      try {
        source.stop();
        source.disconnect();
      } catch {
        // Safe discard
      }
    };
  }

  private createCoffeeShopSound(dest: GainNode): () => void {
    if (!this.ctx) return () => {};
    // Muffled background murmurs & warmth
    const bufferSize = this.ctx.sampleRate * 3;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < bufferSize; i++) {
      data[i] = (Math.random() * 2 - 1) * 0.04;
    }

    const source = this.ctx.createBufferSource();
    source.buffer = buffer;
    source.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(450, this.ctx.currentTime);
    filter.Q.setValueAtTime(1.8, this.ctx.currentTime);

    source.connect(filter);
    filter.connect(dest);
    source.start();

    return () => {
      try {
        source.stop();
        source.disconnect();
      } catch {
        // Safe discard
      }
    };
  }

  private createCampfireSound(dest: GainNode): () => void {
    if (!this.ctx) return () => {};
    // Low rumble + crackles
    const bufferSize = this.ctx.sampleRate * 2;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < bufferSize; i++) {
      // Crackle pops randomly
      const crackle = Math.random() > 0.996 ? (Math.random() * 2 - 1) * 0.4 : 0;
      data[i] = (Math.random() * 2 - 1) * 0.03 + crackle;
    }

    const source = this.ctx.createBufferSource();
    source.buffer = buffer;
    source.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(1200, this.ctx.currentTime);

    source.connect(filter);
    filter.connect(dest);
    source.start();

    return () => {
      try {
        source.stop();
        source.disconnect();
      } catch {
        // Safe discard
      }
    };
  }

  private createForestSound(dest: GainNode): () => void {
    if (!this.ctx) return () => {};
    // Gentle foliage breeze
    const bufferSize = this.ctx.sampleRate * 2;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < bufferSize; i++) {
      data[i] = (Math.random() * 2 - 1) * 0.025;
    }

    const source = this.ctx.createBufferSource();
    source.buffer = buffer;
    source.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(800, this.ctx.currentTime);
    filter.Q.setValueAtTime(0.8, this.ctx.currentTime);

    source.connect(filter);
    filter.connect(dest);
    source.start();

    return () => {
      try {
        source.stop();
        source.disconnect();
      } catch {
        // Safe discard
      }
    };
  }

  private createOceanSound(dest: GainNode): () => void {
    if (!this.ctx) return () => {};
    const bufferSize = this.ctx.sampleRate * 4;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < bufferSize; i++) {
      data[i] = (Math.random() * 2 - 1) * 0.06;
    }

    const source = this.ctx.createBufferSource();
    source.buffer = buffer;
    source.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(350, this.ctx.currentTime);

    // LFO surging wave cycle
    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(0.12, this.ctx.currentTime); // 8 second wave cycle
    const lfoGain = this.ctx.createGain();
    lfoGain.gain.setValueAtTime(300, this.ctx.currentTime);

    lfo.connect(lfoGain);
    lfoGain.connect(filter.frequency);

    source.connect(filter);
    filter.connect(dest);

    lfo.start();
    source.start();

    return () => {
      try {
        lfo.stop();
        source.stop();
        lfo.disconnect();
        source.disconnect();
      } catch {
        // Safe discard
      }
    };
  }
}

export const soundEngine = new SoundEngine();
