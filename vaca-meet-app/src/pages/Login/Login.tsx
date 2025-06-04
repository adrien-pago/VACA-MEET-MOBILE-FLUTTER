import React, { useState, useEffect } from 'react';
import { 
  IonContent, 
  IonPage, 
  IonAlert,
  IonLoading,
  IonText,
  IonCol,
  IonGrid,
  IonRow,
  IonIcon
} from '@ionic/react';
import { personCircleOutline, mailOutline, lockClosedOutline, arrowForwardOutline } from 'ionicons/icons';
import { useIonRouter } from '@ionic/react';
import { AuthService } from '../../services/auth.service';
import AnimatedInput from '../../components/AnimatedInput';
import AnimatedButton from '../../components/AnimatedButton';
import GlassCard from '../../components/GlassCard';
import BackgroundEffects from '../../components/BackgroundEffects';
import './Login.css';

const Login: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showLoading, setShowLoading] = useState(false);
  const [showAlert, setShowAlert] = useState(false);
  const [alertMessage, setAlertMessage] = useState('');
  const [errorDetails, setErrorDetails] = useState<string | null>(null);
  const [errors, setErrors] = useState<{[key: string]: string}>({});
  const [animation, setAnimation] = useState<string>('');
  // Vérifier si nous sommes en mode développement ou production
  const isProduction = process.env.NODE_ENV === 'production';
  
  const router = useIonRouter();
  const authService = new AuthService();
  
  useEffect(() => {
    // Animation de démarrage avec timeout pour assurer le rendu correct
    const timer = setTimeout(() => {
      setAnimation('animate-slide-up');
    }, 50);
    
    // Nettoyage en cas de démontage du composant
    return () => {
      clearTimeout(timer);
      setAnimation('');
    };
  }, []);
  
  const validateForm = () => {
    const newErrors: {[key: string]: string} = {};
    
    if (!username.trim()) {
      newErrors.username = 'Veuillez entrer votre email';
    }
    
    if (!password.trim()) {
      newErrors.password = 'Veuillez entrer votre mot de passe';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleLogin = async () => {
    if (!validateForm()) return;
    
    setShowLoading(true);
    setErrorDetails(null);

    try {
      await authService.login({ username, password });
      setAlertMessage('Connexion réussie !');
      setShowAlert(true);
      
      // Rediriger vers la page d'accueil après connexion
      setTimeout(() => {
        router.push('/home', 'forward', 'replace');
      }, 800);
    } catch (error: any) {
      console.error('Erreur de connexion:', error);
      
      let errorMessage = 'Identifiants incorrects. Veuillez réessayer.';
      let detailedError = '';
      
      if (error.response) {
        detailedError = `Erreur serveur: ${error.response.status} ${error.response.statusText}\n`;
        
        if (error.response.data) {
          if (error.response.data.message) {
            errorMessage = error.response.data.message;
            detailedError += `Message: ${error.response.data.message}\n`;
          }
          
          detailedError += `Données: ${JSON.stringify(error.response.data)}`;
        }
      } else if (error.request) {
        errorMessage = 'Aucune réponse du serveur. Vérifiez votre connexion internet.';
        detailedError = 'La requête a été envoyée mais aucune réponse n\'a été reçue du serveur.\n';
      } else {
        errorMessage = `Erreur de configuration: ${error.message}`;
        detailedError = `Erreur: ${error.message}`;
      }
      
      setAlertMessage(errorMessage);
      setErrorDetails(detailedError);
      setShowAlert(true);
    } finally {
      setShowLoading(false);
    }
  };

  const goToRegister = () => {
    // Animation de transition moderne
    router.push('/register', 'root');
  };

  return (
    <IonPage className="auth-page">
      <BackgroundEffects variant="gradient" density="medium" />
      
      <IonContent fullscreen className="ion-padding auth-content">
        <IonGrid className="full-height">
          <IonRow className="full-height ion-justify-content-center ion-align-items-center">
            <IonCol size="12" sizeMd="8" sizeLg="6" sizeXl="5">
              <div className={`logo-container ${animation}`}>
                <IonIcon 
                  icon={personCircleOutline} 
                  className="auth-logo"
                />
                <h1 className="app-title">Vaca Meet</h1>
              </div>
              
              <GlassCard 
                color="tertiary"
                className={`auth-card ${animation}`}
                animated={false}
              >
                <h2 className="auth-title">
                  Connexion
                </h2>
                              
                <div className="auth-form">
                  <AnimatedInput
                    label="Email"
                    name="username"
                    type="email"
                    value={username}
                    onChange={e => setUsername(e.detail.value!)}
                    icon={mailOutline}
                    required
                    errorMessage={errors.username}
                    autoComplete="email"
                  />
                  
                  <AnimatedInput
                    label="Mot de passe"
                    name="password"
                    type="password"
                    value={password}
                    onChange={e => setPassword(e.detail.value!)}
                    icon={lockClosedOutline}
                    required
                    errorMessage={errors.password}
                    autoComplete="current-password"
                  />
                  
                  <div className="form-actions">
                    <AnimatedButton
                      expand="block"
                      size="large"
                      onClick={handleLogin}
                      icon={arrowForwardOutline}
                      iconPosition="end"
                      className="auth-button"
                      loading={showLoading}
                      pulse={!showLoading}
                    >
                      Se connecter
                    </AnimatedButton>
                    
                    <div className="auth-toggle">
                      <IonText color="medium">
                        Pas encore de compte ?
                      </IonText>
                      
                      <button 
                        className="toggle-button"
                        onClick={goToRegister}
                      >
                        S'inscrire
                      </button>
                    </div>
                  </div>
                  
                </div>
              </GlassCard>
            </IonCol>
          </IonRow>
        </IonGrid>
        
        <IonLoading 
          isOpen={showLoading}
          message="Connexion en cours..."
        />
        
      </IonContent>
    </IonPage>
  );
};

export default Login; 