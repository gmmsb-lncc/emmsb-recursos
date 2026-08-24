# Modos normais e métodos de amostragem ampliada usando movimentos coletivos de proteínas

**Ministrantes:** Ana Ligia Barbour Scott e Paulo Ricardo Batista

## Conteúdo desta pasta

### [`tutorial_mdenm/`](./tutorial_mdenm)

Tutorial de MDeNM (*Molecular Dynamics with excited Normal Modes*) / MDexciteR,
usando lisozima como sistema modelo.

**Roteiro (notebooks Jupyter, também exportados em `.html`):**

| Notebook | Conteúdo |
|----------|----------|
| `tutorial_install.ipynb` | Instalação do R e demais bibliotecas |
| `tutorial_pca_modes.ipynb` | Modos normais e Análise de Componentes Principais (PCA) |
| `tutorial_mdenm.ipynb` | Análise das simulações MDeNM |
| `tutorial_MDexciteR_2022.pdf` | Roteiro das simulações multi-réplica |

**Ambiente:** `create_env.sh` (cria o ambiente conda `tutorial`) e `tutorial.yml`.

**Dados e scripts:**

- `lyso_ca.pdb`, `lyso_ca_sse.pdb`, `ca_eq.pdb` — estruturas (Cα) da lisozima
- `lyso_2019_md_fit_CA.dcd`, `md_skip.dcd`, `experimental_lyso_814s.dcd` — trajetórias
- `pincer_exp.csv`, `pincer_md.csv`, `pincer_mdenm.csv` — ângulos *pincer* calculados
- `calc_pincer.py` — cálculo do ângulo *pincer*
- `catdcd` — utilitário de manipulação de trajetórias DCD
- `deformation.pse` — sessão PyMOL
- `mdenm/` — execução do MDeNM: `config.namd`, `run_mdenm_namd_2022.sh`,
  `mdexciter_namd_nm.R`, `inputs.R`, modos `mode_7.pdb`/`mode_8.pdb`,
  arquivos de equilibração (`step3_input.psf`, `step4_equilibration.*`)
  e campo de força CHARMM36 em `toppar/`
- imagens de apoio: `deformation.png`, `fluctuations.png`, `geostat.png`,
  `lyso_pincer.jpeg`, `pincer_angle_paper.jpeg`, `rmsd_rg_mdexciter_paper.jpeg`,
  `toc_mdexciter.jpeg`
