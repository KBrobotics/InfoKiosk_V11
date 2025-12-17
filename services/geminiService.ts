import { GoogleGenAI } from "@google/genai";
import { Employee, Notification } from "../types";

// Definicja typu dla globalnego obiektu window z naszymi zmiennymi
declare global {
  interface Window {
    _env_?: {
      API_KEY?: string;
    };
  }
}

// Pobieramy klucz z konfiguracji runtime (Docker) LUB z build-time (lokalnie)
const apiKey = window._env_?.API_KEY || process.env.API_KEY || '';

if (!apiKey) {
  console.warn("InfoPoint: Brak klucza API Gemini. Funkcje AI nie będą działać poprawnie.");
}

const ai = new GoogleGenAI({ apiKey: apiKey });

export const geminiService = {
  generateDailyBriefing: async (employee: Employee, notifications: Notification[]): Promise<string> => {
    if (!apiKey) return `Witaj ${employee.firstName}! (Brak konfiguracji AI)`;

    try {
      const pendingCount = notifications.length;
      
      const prompt = `
        You are a helpful workplace assistant system called "InfoPoint".
        Generate a short, friendly, and professional daily briefing message (in Polish) for an employee.
        
        Employee: ${employee.firstName} ${employee.lastName} (${employee.position}).
        Pending Tasks/Notifications: ${pendingCount}.
        
        Details of notifications:
        ${notifications.map(n => `- Type: ${n.type}, Title: ${n.title}`).join('\n')}
        
        Rules:
        1. If they have Urgent or Medical notifications, emphasize the importance gently.
        2. Keep it under 50 words.
        3. Be motivating but professional.
        4. Return ONLY the message text.
      `;

      const response = await ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt,
      });

      return response.text.trim();
    } catch (error) {
      console.error("Gemini Error:", error);
      return `Witaj ${employee.firstName}! Masz ${notifications.length} nowych powiadomień w systemie.`;
    }
  }
};