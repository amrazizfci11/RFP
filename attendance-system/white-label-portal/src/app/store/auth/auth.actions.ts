import { createActionGroup, emptyProps, props } from '@ngrx/store';

export interface LoginCredentials {
  username: string;
  password: string;
}

export interface User {
  id: string;
  username: string;
  email: string;
  name: string;
  role: string;
  companyId?: string;
  companyName?: string;
}

export interface AuthResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
  expiresAt: string;
}

export const AuthActions = createActionGroup({
  source: 'Auth',
  events: {
    'Check Auth': emptyProps(),
    'Login': props<{ credentials: LoginCredentials }>(),
    'Login Success': props<{ response: AuthResponse }>(),
    'Login Failure': props<{ error: string }>(),
    'Logout': emptyProps(),
    'Logout Success': emptyProps(),
    'Refresh Token': emptyProps(),
    'Refresh Token Success': props<{ accessToken: string; refreshToken: string }>(),
    'Refresh Token Failure': props<{ error: string }>(),
    'Update Profile': props<{ user: Partial<User> }>(),
    'Update Profile Success': props<{ user: User }>(),
    'Update Profile Failure': props<{ error: string }>(),
  }
});
