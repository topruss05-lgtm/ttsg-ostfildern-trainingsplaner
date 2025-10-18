import { supabase } from './supabase';
import type { User, Training, Attendance } from './types';

export const db = {
  users: {
    getAll: async (): Promise<User[]> => {
      const { data, error } = await supabase
        .from('users')
        .select('*');

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return (data || []).map(user => ({
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        passwordHash: user.password_hash
      }));
    },

    getById: async (id: string): Promise<User | null> => {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', id)
        .single();

      if (error) return null;
      if (!data) return null;

      // Convert snake_case from database to camelCase for TypeScript
      return {
        id: data.id,
        email: data.email,
        name: data.name,
        role: data.role,
        passwordHash: data.password_hash
      };
    },

    getByEmail: async (email: string): Promise<User | null> => {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .single();

      if (error) return null;
      if (!data) return null;

      // Convert snake_case from database to camelCase for TypeScript
      return {
        id: data.id,
        email: data.email,
        name: data.name,
        role: data.role,
        passwordHash: data.password_hash
      };
    },

    create: async (user: Omit<User, 'id'>): Promise<User> => {
      const { data, error } = await supabase
        .from('users')
        .insert([{
          email: user.email,
          name: user.name,
          role: user.role,
          password_hash: user.passwordHash
        }])
        .select()
        .single();

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return {
        id: data.id,
        email: data.email,
        name: data.name,
        role: data.role,
        passwordHash: data.password_hash
      };
    }
  },

  trainings: {
    getAll: async (): Promise<Training[]> => {
      const { data, error } = await supabase
        .from('trainings')
        .select('*')
        .order('date', { ascending: true });

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return (data || []).map(training => ({
        id: training.id,
        date: training.date,
        time: training.time,
        maxParticipants: training.max_participants,
        trainerId: training.trainer_id,
        trainerName: training.trainer_name
      }));
    },

    getById: async (id: string): Promise<Training | null> => {
      const { data, error } = await supabase
        .from('trainings')
        .select('*')
        .eq('id', id)
        .single();

      if (error) return null;
      if (!data) return null;

      // Convert snake_case from database to camelCase for TypeScript
      return {
        id: data.id,
        date: data.date,
        time: data.time,
        maxParticipants: data.max_participants,
        trainerId: data.trainer_id,
        trainerName: data.trainer_name
      };
    },

    getUpcoming: async (): Promise<Training[]> => {
      const now = new Date().toISOString();
      const { data, error } = await supabase
        .from('trainings')
        .select('*')
        .gte('date', now.split('T')[0])
        .order('date', { ascending: true });

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return (data || []).map(training => ({
        id: training.id,
        date: training.date,
        time: training.time,
        maxParticipants: training.max_participants,
        trainerId: training.trainer_id,
        trainerName: training.trainer_name
      }));
    },

    create: async (training: Omit<Training, 'id'>): Promise<Training> => {
      const { data, error } = await supabase
        .from('trainings')
        .insert([{
          date: training.date,
          time: training.time,
          max_participants: training.maxParticipants,
          trainer_id: training.trainerId,
          trainer_name: training.trainerName
        }])
        .select()
        .single();

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return {
        id: data.id,
        date: data.date,
        time: data.time,
        maxParticipants: data.max_participants,
        trainerId: data.trainer_id,
        trainerName: data.trainer_name
      };
    },

    delete: async (id: string): Promise<void> => {
      const { error } = await supabase
        .from('trainings')
        .delete()
        .eq('id', id);

      if (error) throw error;
    }
  },

  attendances: {
    getAll: async (): Promise<Attendance[]> => {
      const { data, error } = await supabase
        .from('attendances')
        .select('*');

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return (data || []).map(attendance => ({
        id: attendance.id,
        trainingId: attendance.training_id,
        userId: attendance.user_id,
        userName: attendance.user_name,
        status: attendance.status,
        timestamp: attendance.timestamp
      }));
    },

    getByTraining: async (trainingId: string): Promise<Attendance[]> => {
      const { data, error } = await supabase
        .from('attendances')
        .select('*')
        .eq('training_id', trainingId)
        .eq('status', 'attending');

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return (data || []).map(attendance => ({
        id: attendance.id,
        trainingId: attendance.training_id,
        userId: attendance.user_id,
        userName: attendance.user_name,
        status: attendance.status,
        timestamp: attendance.timestamp
      }));
    },

    getByUser: async (userId: string): Promise<Attendance[]> => {
      const { data, error } = await supabase
        .from('attendances')
        .select('*')
        .eq('user_id', userId);

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return (data || []).map(attendance => ({
        id: attendance.id,
        trainingId: attendance.training_id,
        userId: attendance.user_id,
        userName: attendance.user_name,
        status: attendance.status,
        timestamp: attendance.timestamp
      }));
    },

    create: async (attendance: Omit<Attendance, 'id'>): Promise<Attendance> => {
      const { data, error } = await supabase
        .from('attendances')
        .insert([{
          training_id: attendance.trainingId,
          user_id: attendance.userId,
          user_name: attendance.userName,
          status: attendance.status
        }])
        .select()
        .single();

      if (error) throw error;

      // Convert snake_case from database to camelCase for TypeScript
      return {
        id: data.id,
        trainingId: data.training_id,
        userId: data.user_id,
        userName: data.user_name,
        status: data.status,
        timestamp: data.timestamp
      };
    },

    cancel: async (trainingId: string, userId: string): Promise<void> => {
      const { error } = await supabase
        .from('attendances')
        .update({ status: 'cancelled' })
        .eq('training_id', trainingId)
        .eq('user_id', userId);

      if (error) throw error;
    }
  }
};
