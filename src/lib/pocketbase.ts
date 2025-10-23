import PocketBase from 'pocketbase';

// PocketBase Client initialisieren
// Im Production: Umgebungsvariable verwenden
// Im Development: localhost
const PB_URL = import.meta.env.PUBLIC_POCKETBASE_URL || 'http://localhost:8090';

export const pb = new PocketBase(PB_URL);

// Auto-Refresh für Auth deaktivieren (wird manuell gehandhabt)
pb.autoCancellation(false);

// Auth-State im localStorage speichern
pb.authStore.onChange(() => {
  if (typeof window !== 'undefined') {
    console.log('Auth state changed:', pb.authStore.isValid ? 'logged in' : 'logged out');
  }
});
