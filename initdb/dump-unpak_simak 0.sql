DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `userid` char(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` mediumtext NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(50) NOT NULL,
  `level` varchar(255) CHARACTER SET latin1 COLLATE latin1_general_ci NOT NULL COMMENT 'enum(''ADMIN'',''OPERATOR'',''PROGDI'',''BAK'',''DIREKTUR'',''DOSEN'',''MAHASISWA'',''KEUANGAN'',''PUSTAKA'',''MABA'',''PANITIA'',''FAKULTAS'',''LPJM'',''ADMPROGS2'',''ADMPROGS3'',''MBKM'')',
  `aktif` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT 'enum(''Y'',''N'')',
  `sedang_login` enum('Y','N') NOT NULL DEFAULT 'N',
  `waktu_login` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `aksi_terakhir` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IP` varchar(30) NOT NULL DEFAULT '',
  `dpa` enum('Y','N') NOT NULL DEFAULT 'N',
  `nilai` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `m_program_studi`;
CREATE TABLE `m_program_studi` (
  `kode_prodi` char(10) NOT NULL,
  `kode_pt` char(10) NOT NULL,
  `kode_fak` char(9) DEFAULT NULL,
  `kode_jenjang` varchar(1) DEFAULT NULL,
  `kode_jurusan` char(5) NOT NULL,
  `nama_prodi` varchar(50) DEFAULT NULL,
  `alamat` varchar(100) DEFAULT NULL,
  `kode_kabupaten` int(10) DEFAULT NULL,
  `kode_propinsi` int(10) DEFAULT NULL,
  `kode_negara` int(10) DEFAULT NULL,
  `kode_pos` varchar(10) DEFAULT NULL,
  `telepon` varchar(20) DEFAULT NULL,
  `fax` varchar(20) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `website` varchar(50) DEFAULT NULL,
  `sks_lulus` int(11) DEFAULT NULL,
  `status_prodi` varchar(1) DEFAULT NULL,
  `tgl_awal_berdiri` date DEFAULT NULL,
  `semester_awal` varchar(5) DEFAULT NULL,
  `mulai_semester` varchar(5) DEFAULT NULL,
  `no_sk_dikti` varchar(40) DEFAULT NULL,
  `tgl_sk_dikti` date DEFAULT NULL,
  `tgl_akhir_sk_dikti` date DEFAULT NULL,
  `no_sk_ban` varchar(40) DEFAULT NULL,
  `tgl_sk_ban` date DEFAULT NULL,
  `tgl_akhir_sk_ban` date DEFAULT NULL,
  `kode_akreditasi` varchar(1) DEFAULT NULL,
  `frekuensi_kurikulum` varchar(1) DEFAULT NULL,
  `pelaksanaan_kurikulum` varchar(1) DEFAULT NULL,
  `idd_ketua_prodi` varchar(50) DEFAULT NULL,
  `hp_ketua` varchar(20) DEFAULT NULL,
  `idd_nama_operator` varchar(50) DEFAULT NULL,
  `telepon_operator` varchar(20) DEFAULT NULL,
  `nama_sesi` varchar(20) NOT NULL,
  `jumlah_sesi` int(11) NOT NULL,
  `batas_sesi` int(11) NOT NULL,
  `gelar` varchar(20) NOT NULL,
  `gelar_panjang` varchar(200) NOT NULL,
  `no_sk_ban_lama` varchar(40) NOT NULL,
  `logo` varchar(50) DEFAULT NULL,
  `nama_prodi_ing` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`kode_prodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `m_fakultas`;
CREATE TABLE `m_fakultas` (
  `kode_fakultas` char(9) NOT NULL,
  `kode_pt` char(10) NOT NULL,
  `nama_fakultas` varchar(100) NOT NULL DEFAULT '',
  `pejabat` varchar(50) DEFAULT NULL,
  `jabatan` char(1) DEFAULT NULL,
  `wakil_pejabat` varchar(50) DEFAULT NULL,
  `wakil_pejabat_adm` varchar(50) DEFAULT NULL,
  `logo` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`kode_fakultas`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `m_mahasiswa`;
CREATE TABLE `m_mahasiswa` (
  `kode_pt` char(10) DEFAULT NULL,
  `kode_fak` char(9) NOT NULL,
  `kode_jurusan` char(5) NOT NULL,
  `kode_jenjang` varchar(1) DEFAULT NULL,
  `kode_prodi` char(10) NOT NULL,
  `NIM` varchar(20) NOT NULL,
  `nama_mahasiswa` varchar(100) DEFAULT NULL,
  `warga_negara` char(1) NOT NULL,
  `status_sipil` char(1) NOT NULL,
  `agama` varchar(1) NOT NULL,
  `jenis_kelamin` varchar(1) DEFAULT NULL,
  `tempat_lahir` varchar(20) DEFAULT NULL,
  `tanggal_lahir` date NOT NULL DEFAULT '9999-12-31',
  `telepon` varchar(50) DEFAULT NULL,
  `hp` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `foto` varchar(50) NOT NULL DEFAULT '',
  `alamat` text,
  `kode_kabupaten` varchar(50) DEFAULT NULL,
  `kode_propinsi` varchar(50) DEFAULT NULL,
  `kode_negara` varchar(50) DEFAULT NULL,
  `kode_pos` varchar(50) NOT NULL DEFAULT '',
  `status_masuk` varchar(1) DEFAULT NULL,
  `tahun_masuk` varchar(4) DEFAULT NULL,
  `semester_masuk` varchar(5) NOT NULL,
  `tanggal_masuk` date NOT NULL DEFAULT '9999-12-31',
  `tanggal_lulus` date DEFAULT NULL,
  `batas_studi` varchar(5) DEFAULT NULL,
  `masuk_kelas` varchar(5) DEFAULT NULL,
  `semester` int(2) DEFAULT '0',
  `status_aktif` varchar(1) NOT NULL,
  `kode_sekolah` varchar(10) DEFAULT NULL,
  `nama_sekolah` varchar(100) NOT NULL,
  `nis_asal` varchar(10) DEFAULT NULL,
  `nilai_un` varchar(21) DEFAULT NULL,
  `kode_asal_pt` varchar(10) DEFAULT NULL,
  `nama_asal_pt` varchar(100) NOT NULL,
  `nim_asal` varchar(15) DEFAULT NULL,
  `asal_jenjang` varchar(1) DEFAULT NULL,
  `kode_asal_prodi` varchar(5) DEFAULT NULL,
  `sks_diakui` int(11) DEFAULT NULL,
  `kode_biaya` varchar(1) DEFAULT NULL,
  `kode_kerja` varchar(1) DEFAULT NULL,
  `nama_tempat_kerja` varchar(40) DEFAULT NULL,
  `kode_tempat_kerja` varchar(6) DEFAULT NULL,
  `kode_pos_tempat_kerja` varchar(5) DEFAULT NULL,
  `NIDN_promotor` varchar(10) DEFAULT NULL,
  `NIDN_kopromotor_1` varchar(10) DEFAULT NULL,
  `NIDN_kopromotor_2` varchar(10) DEFAULT NULL,
  `NIDN_kopromotor_3` varchar(10) DEFAULT NULL,
  `NIDN_kopromotor_4` varchar(10) DEFAULT NULL,
  `yudisium` enum('N','Y') NOT NULL DEFAULT 'N',
  `no_sk_yudisium` varchar(50) NOT NULL,
  `tgl_sk_yudisium` date NOT NULL,
  `no_ijazah` varchar(50) DEFAULT NULL,
  `shift` char(2) DEFAULT NULL,
  `NIDN_pa` varchar(50) DEFAULT NULL,
  `nama_asal_prodi` varchar(150) NOT NULL,
  `NIRM` varchar(30) NOT NULL,
  `nik` varchar(20) NOT NULL,
  `rt` varchar(4) NOT NULL,
  `rw` varchar(4) NOT NULL,
  `dusun` varchar(50) NOT NULL,
  `desa` varchar(50) NOT NULL,
  `kecamatan` varchar(50) NOT NULL,
  `jenis_tinggal` decimal(2,0) NOT NULL,
  `wilayah` char(6) NOT NULL DEFAULT '000000',
  `feeder` char(1) NOT NULL DEFAULT '0',
  `error` mediumtext NOT NULL,
  `keb_khusus` varchar(40) DEFAULT NULL,
  `asal_negara` char(1) DEFAULT NULL,
  `asal_jenjang_emis` char(1) DEFAULT NULL,
  `nisn` char(50) DEFAULT NULL,
  `mulai_semester` int(2) DEFAULT NULL,
  `tahun_lulus_sekolah` varchar(4) DEFAULT NULL,
  `jur_sekolah` varchar(100) DEFAULT NULL,
  `tanggal_beri_ijazah` date DEFAULT NULL,
  `tanggal_beri_ijazah_rev` date DEFAULT NULL,
  `tanggal_beri_transkrip` date DEFAULT NULL,
  `NIM_rev` varchar(20) DEFAULT NULL,
  `nama_mahasiswa_rev` varchar(100) DEFAULT NULL,
  `tahun_masuk_rev` varchar(4) DEFAULT NULL,
  `tgl_sk_yudisium_rev` date DEFAULT NULL,
  `tempat_lahir_rev` varchar(20) DEFAULT NULL,
  `tanggal_lahir_rev` date DEFAULT NULL,
  `tanggal_beri_transkrip_rev` date DEFAULT NULL,
  `gelar_rev` varchar(35) DEFAULT NULL,
  `gelar_panjang_rev` varchar(50) DEFAULT NULL,
  `no_ijazah_rev` varchar(50) DEFAULT NULL,
  `alamat_rev` text,
  `idks` char(7) NOT NULL,
  `toefl` char(6) DEFAULT NULL,
  `lb_toefl` varchar(100) DEFAULT NULL,
  `pin_ijazah` varchar(30) DEFAULT NULL,
  `npwp` varchar(15) CHARACTER SET ascii DEFAULT NULL,
  `jalur_masuk` char(2) DEFAULT NULL,
  `pembiayaan_awal` char(2) DEFAULT '1',
  `biaya_masuk` int(11) DEFAULT '0',
  `similarity` int(2) DEFAULT NULL,
  `no_transkrip` varchar(100) DEFAULT NULL,
  `santri` enum('N','Y') NOT NULL DEFAULT 'N',
  `kode_pp` char(3) DEFAULT NULL,
  `NISantri` varchar(50) DEFAULT NULL,
  `saldo` bigint(16) NOT NULL DEFAULT '0',
  PRIMARY KEY (`NIM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `m_dosen`;
CREATE TABLE `m_dosen` (
  `NIDN` varchar(50) NOT NULL,
  `nip_lama` varchar(30) NOT NULL,
  `nip_baru` varchar(30) NOT NULL,
  `kode_pt` char(10) DEFAULT NULL,
  `kode_fak` char(9) DEFAULT NULL,
  `kode_jurusan` char(5) DEFAULT NULL,
  `kode_prodi` char(10) DEFAULT NULL,
  `kode_jenjang` varchar(3) NOT NULL,
  `nama_dosen` varchar(50) NOT NULL DEFAULT '',
  `gelar_depan` varchar(30) DEFAULT NULL,
  `gelar_belakang` varchar(30) DEFAULT NULL,
  `agama` varchar(1) DEFAULT NULL,
  `jenis_kelamin` varchar(1) NOT NULL,
  `tempat_lahir` varchar(50) NOT NULL DEFAULT '',
  `tanggal_lahir` date NOT NULL DEFAULT '0000-00-00',
  `ktp` varchar(50) NOT NULL DEFAULT '',
  `telephon` varchar(50) DEFAULT NULL,
  `hp` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `alamat` mediumtext,
  `kode_kabupaten` varchar(50) DEFAULT NULL,
  `kode_propinsi` varchar(50) DEFAULT NULL,
  `kode_negara` varchar(50) DEFAULT NULL,
  `kode_pos` varchar(50) NOT NULL DEFAULT '',
  `mulai_masuk` date NOT NULL DEFAULT '0000-00-00',
  `mulai_semester` varchar(5) NOT NULL DEFAULT '',
  `kode_ikatan_kerja` varchar(1) DEFAULT NULL,
  `kode_pendidikan` varchar(1) NOT NULL,
  `instansi_induk` varchar(20) NOT NULL,
  `status_aktif` varchar(1) NOT NULL,
  `pangkat_golongan` varchar(10) DEFAULT NULL,
  `jabatan_akademik` varchar(1) NOT NULL,
  `jabatan_fungsional` varchar(50) DEFAULT NULL,
  `jabatan_struktural` varchar(100) DEFAULT NULL,
  `foto` varchar(200) NOT NULL,
  `nomor_dos` varchar(10) NOT NULL,
  `akta_dos` varchar(50) NOT NULL,
  `nik` varchar(20) NOT NULL,
  `rt` varchar(4) NOT NULL,
  `rw` varchar(4) NOT NULL,
  `dusun` varchar(50) NOT NULL,
  `desa` varchar(50) NOT NULL,
  `kecamatan` char(8) NOT NULL,
  `jenis_tinggal` decimal(2,0) NOT NULL,
  `nama_ibu` varchar(50) NOT NULL,
  `npwp` varchar(15) NOT NULL,
  `status_pegawai` varchar(2) NOT NULL,
  `sk_cpns` varchar(40) DEFAULT NULL,
  `tgl_sk_cpns` date DEFAULT NULL,
  `sk_angkat` varchar(40) DEFAULT NULL,
  `tmt_sk_angkat` date DEFAULT NULL,
  `id_lemb_angkat` int(2) NOT NULL,
  `id_sumber_gaji` char(2) NOT NULL,
  `stat_kawin` char(1) NOT NULL DEFAULT '0',
  `nm_suami_istri` varchar(50) NOT NULL,
  `nip_suami_istri` char(18) NOT NULL,
  `tmt_pns` date NOT NULL,
  `id_pekerjaan_suami_istri` char(2) NOT NULL,
  `wilayah` char(6) NOT NULL DEFAULT '000000',
  `ktm` varchar(40) DEFAULT NULL,
  `sertifikasi` varchar(1) NOT NULL,
  `sk_fungsional` char(50) DEFAULT NULL,
  `keahlian` char(50) DEFAULT NULL,
  PRIMARY KEY (`NIDN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tabel Dosen';
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `r_prodi`;
CREATE TABLE `r_prodi` (
  `kode_prodi` char(10) NOT NULL,
  `nama_prodi` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`kode_prodi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;